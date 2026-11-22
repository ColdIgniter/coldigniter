#!/usr/bin/env python3
"""Run the request tests against a real ColdFusion MX 6.1 server.

    python3 tests/box/run.py            upload, test, clean up
    python3 tests/box/run.py --keep     leave the scratch copy on the server
    python3 tests/box/run.py --clean    only remove a scratch copy left behind

Nothing proves that the code runs on 6.1 except the server itself, so this
uploads a scratch copy of app, system and writable (plus tests/_support on
top of it) over FTP, next to the real site, with its own front controller
in public/_t<tag>/. Then it makes the requests in cases.py and compares.

Settings come from the environment:
    COLDIGNITER_TEST_HOST   the site, default coldigniter.lan
    COLDIGNITER_TEST_TAG    suffix of the scratch folders, default "ci";
                            two runs at the same time need different tags

The FTP user and password are read from ~/.netrc (machine = the host).
The FTP root must be the folder that holds app, system and public.
"""
import ftplib
import http.client
import io
import netrc
import os
import sys
import time
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
SUPPORT = os.path.join(ROOT, "tests", "_support")
HOST = os.environ.get("COLDIGNITER_TEST_HOST", "coldigniter.lan")
TAG = os.environ.get("COLDIGNITER_TEST_TAG", "ci")
BACK = "_tb" + TAG
FRONT = "public/_t" + TAG

sys.path.insert(0, HERE)
from cases import CASES  # noqa: E402


def collect():
    """Every file of the scratch copy: path on the server -> bytes."""
    files = {}
    for top in ("app", "system", "writable"):
        for base, _, names in os.walk(os.path.join(ROOT, top)):
            for name in names:
                full = os.path.join(base, name)
                with open(full, "rb") as handle:
                    files[BACK + "/" + os.path.relpath(full, ROOT)] = handle.read()
    for base, _, names in os.walk(SUPPORT):
        for name in names:
            full = os.path.join(base, name)
            with open(full, "rb") as handle:
                files[BACK + "/" + os.path.relpath(full, SUPPORT)] = handle.read()

    # The front controller sits one folder deeper than the real one.
    with open(os.path.join(ROOT, "public", "index.cfm"), "rb") as handle:
        index = handle.read()
    old = b'"../app/Config/Paths.cfm"'
    if old not in index:
        sys.exit("public/index.cfm no longer includes " + old.decode())
    files[FRONT + "/index.cfm"] = index.replace(old, ('"../../' + BACK + '/app/Config/Paths.cfm"').encode())
    return files


def folders(files):
    found = []
    for path in files:
        parts = path.split("/")[:-1]
        for i in range(1, len(parts) + 1):
            folder = "/".join(parts[:i])
            if folder not in found and folder != "public":
                found.append(folder)
    return found


def connect():
    auth = netrc.netrc().authenticators(HOST)
    if auth is None:
        sys.exit("no entry for machine " + HOST + " in ~/.netrc")
    ftp = ftplib.FTP(HOST, timeout=30)
    ftp.login(auth[0], auth[2])
    return ftp


def upload(ftp, files):
    for folder in folders(files):
        try:
            ftp.mkd("/" + folder)
        except ftplib.error_perm:
            pass
    for path in sorted(files):
        ftp.storbinary("STOR /" + path, io.BytesIO(files[path]))
    print("uploaded %d files to %s" % (len(files), HOST))


def clean(ftp, files):
    for path in files:
        try:
            ftp.delete("/" + path)
        except ftplib.all_errors:
            pass
    # The server keeps the folders open for about half a minute after the last request.
    time.sleep(35)
    for folder in sorted(folders(files), key=len, reverse=True):
        try:
            ftp.rmd("/" + folder)
        except ftplib.all_errors as error:
            print("cleanup: %s: %s" % (folder, error))
    print("cleaned up")


def fetch(case):
    target = "/" + FRONT.split("/", 1)[1] + "/index.cfm"
    if case["route"]:
        target += "?" + urllib.parse.quote(case["route"], safe="/")
    connection = http.client.HTTPConnection(HOST, timeout=90)
    connection.request(case.get("method", "GET"), target, headers={"Content-Length": "0"} if case.get("method") == "POST" else {})
    response = connection.getresponse()
    body = response.read().decode("latin-1")
    connection.close()
    return response, body


def run_cases():
    failed = 0
    for case in CASES:
        label = "%s %s" % (case.get("method", "GET"), case["route"] or "/")
        problems = []
        try:
            response, body = fetch(case)
        except OSError as error:
            problems.append("request failed: %s" % error)
        else:
            if response.status != case["status"]:
                problems.append("status %d, expected %d" % (response.status, case["status"]))
            for text in case.get("contains", []):
                if text not in body:
                    problems.append("body does not contain %r" % text)
            for text in case.get("lacks", []):
                if text in body:
                    problems.append("body contains %r" % text)
            for name, value in case.get("headers", {}).items():
                if response.getheader(name) != value:
                    problems.append("header %s is %r, expected %r" % (name, response.getheader(name), value))
            if problems:
                problems.append("body starts: %r" % " ".join(body.split())[:300])
        if problems:
            failed += 1
            print("FAIL  " + label)
            for problem in problems:
                print("      " + problem)
        else:
            print("ok    " + label)
    print("%d cases, %d failed" % (len(CASES), failed))
    return failed


def main():
    files = collect()
    for path, data in files.items():
        try:
            data.decode("ascii")
        except UnicodeDecodeError:
            sys.exit(path + " is not ASCII")

    ftp = connect()
    if "--clean" in sys.argv:
        clean(ftp, files)
        ftp.quit()
        return 0

    failed = 1
    try:
        upload(ftp, files)
        failed = run_cases()
    finally:
        if "--keep" not in sys.argv:
            try:
                ftp.voidcmd("NOOP")
            except ftplib.all_errors:
                ftp = connect()
            clean(ftp, files)
        ftp.quit()
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
