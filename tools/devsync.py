#!/usr/bin/env python3
"""devsync: keep a CFML host's copy of this working tree up to date over FTP.

The source of truth is the working tree on the development machine. devsync
pushes it to a host that runs the code natively (for example IIS and
ColdFusion on Windows NT) and keeps pushing as files change.

What is synced
    Every file git knows about or would add: tracked files plus untracked
    files that are not ignored, and every folder, empty ones included.
    Uncommitted edits are included. Ignored files and folders, symlinks,
    nested repositories and the .git, .claude, .fleet-out and __pycache__
    folders are not.

How changes are tracked
    Old FTP servers do not report file times, so devsync keeps its own
    record of what it put on the host (a content hash per file, and the
    folders it created) in a state file under ~/.local/state. It only ever
    removes files and folders that it put there itself; anything else on the
    host, such as cache or log files written there, is left alone.

Credentials
    Read from ~/.netrc, keyed by host name:
        machine <host> login <user> password <password>

Usage
    devsync.py push   --host HOST        upload what changed, once
    devsync.py watch  --host HOST        keep uploading as files change
    devsync.py status --host HOST        show what a push would do
    devsync.py install --host HOST       run "watch" as a systemd user service
    devsync.py uninstall                 remove that service

    --src DIR          working tree to sync (default: the tree devsync is in)
    --remote-dir DIR   folder on the host, relative to the FTP login folder
    --exclude GLOB     extra paths to skip, may be repeated
    push --full        send every folder and file again, whatever the state
                       file says

Python 3.9 or later, standard library only.
"""

import argparse
import fnmatch
import ftplib
import hashlib
import io
import json
import netrc
import os
import posixpath
import shutil
import stat
import subprocess
import sys
import time

BUILTIN_EXCLUDES = (".git", ".claude", ".fleet-out", "__pycache__")
SERVICE = "coldigniter-devsync.service"
INSTALL_DIR = os.path.expanduser("~/.local/lib/coldigniter-devsync")
RETRYABLE = ftplib.all_errors + (subprocess.CalledProcessError,)


def log(message):
    print(message, flush=True)


# --------------------------------------------------------------------------
# local side
# --------------------------------------------------------------------------

def git_list(src, *options):
    out = subprocess.run(["git", "-C", src, "ls-files", "-z"] + list(options),
                         check=True, capture_output=True).stdout
    return [raw.decode("utf-8", "surrogateescape") for raw in out.split(b"\0") if raw]


def excluded(path, excludes):
    return any(fnmatch.fnmatch(path, glob) or fnmatch.fnmatch(path + "/", glob)
               for glob in excludes)


def list_folders(src, excludes):
    """Return every folder to sync, empty ones included."""
    ignored = {path.rstrip("/") for path in
               git_list(src, "-oi", "--exclude-standard", "--directory")
               if path.endswith("/")}
    folders = set()
    for root, names, _ in os.walk(src):
        keep = []
        for name in names:
            full = os.path.join(root, name)
            path = os.path.relpath(full, src).replace(os.sep, "/")
            if name in BUILTIN_EXCLUDES or path in ignored or excluded(path, excludes):
                continue
            if os.path.islink(full) or os.path.lexists(os.path.join(full, ".git")):
                continue                # a link, or a nested repository or worktree
            keep.append(name)
            folders.add(path)
        names[:] = keep
    return folders


def list_files(src, excludes):
    """Return {relative path: (size, mtime_ns)} for every file to sync."""
    files = {}
    for path in git_list(src, "-co", "--exclude-standard"):
        if path.endswith("/"):          # a nested repository or worktree
            continue
        if any(part in BUILTIN_EXCLUDES for part in path.split("/")[:-1]):
            continue
        if excluded(path, excludes):
            continue
        try:
            info = os.lstat(os.path.join(src, path))
        except OSError:                 # tracked but deleted in the tree
            continue
        if stat.S_ISREG(info.st_mode):
            files[path] = (info.st_size, info.st_mtime_ns)
    return files


def sha1(data):
    return hashlib.sha1(data).hexdigest()


def parents(path):
    folder = posixpath.dirname(path)
    while folder:
        yield folder
        folder = posixpath.dirname(folder)


class Tree:
    """The local tree, with a cache so unchanged files are not re-read."""

    def __init__(self, src, excludes):
        self.src = src
        self.excludes = excludes
        self.cache = {}                 # path -> (signature, hash)

    def read(self, path):
        with open(os.path.join(self.src, path), "rb") as handle:
            return handle.read()

    def scan(self):
        """Return ({path: content hash}, {folders}) for the tree as it is now."""
        hashes = {}
        files = list_files(self.src, self.excludes)
        for path, signature in files.items():
            cached = self.cache.get(path)
            if cached and cached[0] == signature:
                hashes[path] = cached[1]
                continue
            try:
                digest = sha1(self.read(path))
            except OSError:             # vanished between listing and reading
                continue
            self.cache[path] = (signature, digest)
            hashes[path] = digest
        for path in list(self.cache):
            if path not in files:
                del self.cache[path]
        folders = list_folders(self.src, self.excludes)
        for path in hashes:
            folders.update(parents(path))
        return hashes, folders


# --------------------------------------------------------------------------
# state file: what this tool has put on the host
# --------------------------------------------------------------------------

def state_path(host, remote_dir):
    base = os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state")
    name = host + "_" + (remote_dir.strip("/").replace("/", "_") or "root")
    return os.path.join(base, "coldigniter-devsync", name + ".json")


def load_state(path):
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
    except FileNotFoundError:
        data = {}
    return {"files": data.get("files", {}), "dirs": set(data.get("dirs", []))}


def save_state(path, state):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    temp = path + ".tmp"
    with open(temp, "w", encoding="utf-8") as handle:
        json.dump({"files": state["files"], "dirs": sorted(state["dirs"])},
                  handle, indent=0, sort_keys=True)
    os.replace(temp, path)


# --------------------------------------------------------------------------
# remote side
# --------------------------------------------------------------------------

def is_missing(error):
    text = str(error).lower()
    return "cannot find" in text or "no such" in text


class Remote:
    RMDIR_WAIT = 10                     # seconds between tries at a busy folder
    RMDIR_TRIES = 6

    def __init__(self, host, port, remote_dir, timeout=20):
        self.host = host
        self.port = port
        self.root = "/" + remote_dir.strip("/")
        self.timeout = timeout
        self.ftp = None
        self.busy = {}                  # folder -> (retry time, tries so far)
        self.last_used = 0.0

    def connect(self):
        try:
            auth = netrc.netrc().authenticators(self.host)
        except (OSError, netrc.NetrcParseError) as error:
            raise SystemExit(f"devsync: cannot read ~/.netrc: {error}")
        if not auth:
            raise SystemExit(f"devsync: no entry for {self.host} in ~/.netrc")
        ftp = ftplib.FTP(timeout=self.timeout)
        ftp.connect(self.host, self.port)
        ftp.login(auth[0], auth[2])
        ftp.set_pasv(True)
        self.ftp = ftp
        self.last_used = time.monotonic()

    def reset(self):
        if self.ftp is not None:
            try:
                self.ftp.close()
            except Exception:
                pass
        self.ftp = None

    def ensure(self):
        """Make sure there is a live connection, reconnecting if it went stale."""
        if self.ftp is not None and time.monotonic() - self.last_used > 15:
            try:
                self.ftp.voidcmd("NOOP")
            except ftplib.all_errors:
                self.reset()
        if self.ftp is None:
            self.connect()
        self.last_used = time.monotonic()

    def keepalive(self):
        if self.ftp is not None and time.monotonic() - self.last_used > 60:
            self.ensure()

    def full(self, path):
        return posixpath.join(self.root, path)

    def make_dir(self, folder):
        try:
            self.ftp.mkd(self.full(folder))
        except ftplib.error_perm as error:
            if "exist" not in str(error).lower():
                raise
        self.last_used = time.monotonic()

    def put(self, path, data):
        target = "STOR " + self.full(path)
        try:
            self.ftp.storbinary(target, io.BytesIO(data))
        except ftplib.error_perm:
            # The folder may have been removed on the host; rebuild it once.
            for folder in reversed(list(parents(path))):
                self.make_dir(folder)
            self.ftp.storbinary(target, io.BytesIO(data))
        self.last_used = time.monotonic()

    def delete(self, path):
        try:
            self.ftp.delete(self.full(path))
        except ftplib.error_perm as error:
            if not is_missing(error):
                raise
        self.last_used = time.monotonic()

    def can_try(self, folder):
        return self.busy.get(folder, (0, 0))[0] <= time.monotonic()

    def remove_dir(self, folder):
        """Remove a folder. Returns "removed", "wait" or "kept".

        A web server can hold a deleted file open for a while, and until it
        lets go the folder counts as not empty. Such a folder is retried a
        few times and then left in place, as it may hold files that were
        created on the host.
        """
        try:
            self.ftp.rmd(self.full(folder))
        except ftplib.error_perm as error:
            if is_missing(error):
                self.busy.pop(folder, None)
                return "removed"
            if "not empty" not in str(error).lower():
                raise
            tries = self.busy.get(folder, (0, 0))[1] + 1
            if tries >= self.RMDIR_TRIES:
                self.busy.pop(folder, None)
                return "kept"
            self.busy[folder] = (time.monotonic() + self.RMDIR_WAIT, tries)
            return "wait"
        self.busy.pop(folder, None)
        self.last_used = time.monotonic()
        return "removed"


# --------------------------------------------------------------------------
# sync
# --------------------------------------------------------------------------

def plan(tree, state, remote=None, full=False):
    """Work out what differs between the tree and what was last sent."""
    hashes, folders = tree.scan()
    sent, sent_dirs = state["files"], state["dirs"]
    gone = sent_dirs - folders
    if remote is not None:
        gone = {folder for folder in gone if remote.can_try(folder)}
    return {
        "delete": sorted(path for path in sent if path not in hashes),
        "rmdir": sorted(gone, reverse=True),            # deepest first
        "mkdir": sorted(folders if full else folders - sent_dirs),
        "upload": sorted(path for path in hashes if full or sent.get(path) != hashes[path]),
    }


def sync(tree, remote, state, state_file, full=False):
    """Bring the host in line with the tree. Returns the number of changes."""
    todo = plan(tree, state, remote, full)
    if not any(todo.values()):
        return 0
    started = time.monotonic()
    sent, sent_dirs = state["files"], state["dirs"]
    changes = 0
    try:
        remote.ensure()
        # Deletes go first so that a rename that only changes letter case
        # works on a host whose file names are not case sensitive.
        for path in todo["delete"]:
            remote.delete(path)
            del sent[path]
            changes += 1
            log(f"  deleted         {path}")
        for folder in todo["rmdir"]:
            outcome = remote.remove_dir(folder)
            if outcome == "wait":
                continue
            sent_dirs.discard(folder)
            changes += 1
            if outcome == "removed":
                log(f"  removed folder  {folder}/")
            else:
                log(f"  kept folder     {folder}/ (not empty on the host)")
        for folder in todo["mkdir"]:
            remote.make_dir(folder)
            sent_dirs.add(folder)
            changes += 1
            log(f"  created folder  {folder}/")
        for path in todo["upload"]:
            try:
                data = tree.read(path)
            except OSError:
                continue                # gone again; the next pass deletes it
            remote.put(path, data)
            sent[path] = sha1(data)
            changes += 1
            log(f"  uploaded        {path} ({len(data)} bytes)")
    finally:
        if changes:
            save_state(state_file, state)
    if changes:
        elapsed = (time.monotonic() - started) * 1000
        log(f"synced {changes} change(s) in {elapsed:.0f} ms")
    return changes


def cmd_push(args):
    tree, remote, state_file = setup(args)
    state = load_state(state_file)
    try:
        changes = sync(tree, remote, state, state_file, args.full)
    finally:
        remote.reset()
    if not changes:
        log("nothing to do")
    return 0


def cmd_status(args):
    tree, _, state_file = setup(args)
    todo = plan(tree, load_state(state_file))
    labels = (("delete", "would delete"), ("rmdir", "would remove folder"),
              ("mkdir", "would create folder"), ("upload", "would upload"))
    for key, label in labels:
        for path in todo[key]:
            log(f"  {label}  {path}")
    log(", ".join(f"{len(todo[key])} to {key}" for key, _ in labels))
    return 0


def cmd_watch(args):
    tree, remote, state_file = setup(args)
    state = load_state(state_file)
    log(f"watching {tree.src} -> ftp://{remote.host}{remote.root}")
    delay = 1.0
    while True:
        try:
            sync(tree, remote, state, state_file)
            remote.keepalive()
            delay = 1.0
            time.sleep(args.interval)
        except RETRYABLE as error:
            log(f"error: {type(error).__name__}: {error}; retrying in {delay:.0f} s")
            remote.reset()
            time.sleep(delay)
            delay = min(delay * 2, 30.0)
        except KeyboardInterrupt:
            remote.reset()
            return 0


# --------------------------------------------------------------------------
# service
# --------------------------------------------------------------------------

def unit_path():
    return os.path.expanduser("~/.config/systemd/user/" + SERVICE)


def quote(value):
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def cmd_install(args):
    src = resolve_src(args)
    if not args.host:
        raise SystemExit("devsync: --host is required")
    os.makedirs(INSTALL_DIR, exist_ok=True)
    script = os.path.join(INSTALL_DIR, "devsync.py")
    # The service runs a copy, so it keeps working whichever branch the
    # working tree is on.
    shutil.copyfile(os.path.abspath(__file__), script)
    command = [sys.executable, "-B", script, "watch", "--src", src, "--host", args.host,
               "--port", str(args.port), "--remote-dir", args.remote_dir,
               "--interval", str(args.interval)]
    for glob in args.exclude:
        command += ["--exclude", glob]
    unit = "\n".join([
        "[Unit]",
        f"Description=ColdIgniter dev sync: {src} to {args.host}",
        "After=network-online.target",
        "",
        "[Service]",
        "ExecStart=" + " ".join(quote(part) for part in command),
        "Environment=PYTHONUNBUFFERED=1",
        "Restart=always",
        "RestartSec=10",
        "",
        "[Install]",
        "WantedBy=default.target",
        "",
    ])
    os.makedirs(os.path.dirname(unit_path()), exist_ok=True)
    with open(unit_path(), "w", encoding="utf-8") as handle:
        handle.write(unit)
    subprocess.run(["systemctl", "--user", "daemon-reload"], check=True)
    subprocess.run(["systemctl", "--user", "enable", SERVICE], check=True)
    subprocess.run(["systemctl", "--user", "restart", SERVICE], check=True)
    log(f"installed and started {SERVICE}")
    log(f"logs: journalctl --user -u {SERVICE} -f")
    return 0


def cmd_uninstall(args):
    subprocess.run(["systemctl", "--user", "disable", "--now", SERVICE], check=False)
    for path in (unit_path(), os.path.join(INSTALL_DIR, "devsync.py")):
        if os.path.exists(path):
            os.remove(path)
    subprocess.run(["systemctl", "--user", "daemon-reload"], check=False)
    log(f"removed {SERVICE}")
    return 0


# --------------------------------------------------------------------------
# command line
# --------------------------------------------------------------------------

def resolve_src(args):
    start = args.src or os.path.dirname(os.path.abspath(__file__))
    found = subprocess.run(["git", "-C", start, "rev-parse", "--show-toplevel"],
                           capture_output=True, text=True)
    if found.returncode != 0:
        raise SystemExit(f"devsync: {start} is not inside a git working tree")
    return found.stdout.strip()


def setup(args):
    if not args.host:
        raise SystemExit("devsync: --host is required (or set DEVSYNC_HOST)")
    tree = Tree(resolve_src(args), args.exclude)
    remote = Remote(args.host, args.port, args.remote_dir)
    return tree, remote, state_path(args.host, args.remote_dir)


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="devsync.py", description="Keep a CFML host's copy of this tree up to date over FTP.")
    sub = parser.add_subparsers(dest="command", required=True)
    commands = {"push": cmd_push, "watch": cmd_watch, "status": cmd_status,
                "install": cmd_install, "uninstall": cmd_uninstall}
    for name in commands:
        cmd = sub.add_parser(name)
        if name == "uninstall":
            continue
        cmd.add_argument("--src", help="working tree to sync")
        cmd.add_argument("--host", default=os.environ.get("DEVSYNC_HOST"))
        cmd.add_argument("--port", type=int, default=21)
        cmd.add_argument("--remote-dir", default="/")
        cmd.add_argument("--exclude", action="append", default=[], metavar="GLOB")
        cmd.add_argument("--interval", type=float, default=0.5,
                         help="seconds between checks in watch mode")
        if name == "push":
            cmd.add_argument("--full", action="store_true",
                             help="send every folder and file again")
    args = parser.parse_args(argv)
    return commands[args.command](args)


if __name__ == "__main__":
    sys.exit(main())
