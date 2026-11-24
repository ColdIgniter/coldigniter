#!/usr/bin/env python3
"""Static checks for the CFML source. Needs nothing but Python 3.

    python3 tests/lint.py

Checks every .cfm and .cfc file under app, system, public and tests for
the rules that are easy to break and that need no server to detect:

  ascii      only ASCII bytes
  wording    the source never names the language of the upstream
  script     no cfscript blocks
  output     every cfcomponent and cffunction has output="no"
  operators  word operators only in cfif, cfelseif, cfset and cfreturn
  var        var lines come first in a function
  dupvar     a var line does not repeat an argument or another var name
  appcfc     no Application.cfc (it is ignored by the target server)

Exit status 0 when clean, 1 when something was found.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FOLDERS = ("app", "system", "public", "tests")

COMMENT = re.compile(r"<!---.*?--->", re.S)
STRING = re.compile(r'"[^"]*"|\'[^\']*\'')
TAG = re.compile(r"<(/?)(cf\w+)\b([^>]*)>", re.I)
FUNCTION = re.compile(r"<cffunction\b.*?</cffunction>", re.S | re.I)
WORDING = re.compile("p" + "hp", re.I)
BUILTINS = ("encrypt", "decrypt", "hash", "tobase64", "tobinary", "find", "insert", "replace", "log")
SYMBOLS = re.compile(r"==|!=|&&|\|\||\+\+|\+=|-=|<=|>=")


def blank(match):
    """Replace a match by spaces, keeping the line breaks, so line numbers stay right."""
    return re.sub(r"[^\n]", " ", match.group(0))


def line_of(text, position):
    return text.count("\n", 0, position) + 1


def check(path, raw):
    found = []

    try:
        text = raw.decode("ascii")
    except UnicodeDecodeError as error:
        return [(line_of(raw.decode("latin-1"), error.start), "ascii", "non-ASCII byte")]

    for match in WORDING.finditer(text):
        found.append((line_of(text, match.start()), "wording", "names the language of the upstream"))

    code = COMMENT.sub(blank, text)

    for match in TAG.finditer(code):
        closing, name, rest = match.group(1), match.group(2).lower(), match.group(3)
        line = line_of(code, match.start())
        if closing:
            continue
        if name == "cfscript":
            found.append((line, "script", "cfscript block"))
        if name in ("cfcomponent", "cffunction") and not re.search(r'\boutput\s*=\s*"no"', rest, re.I):
            found.append((line, "output", name + ' without output="no"'))
        if name == "cffunction":
            access = re.search(r'\baccess\s*=\s*"(\w*)"', rest, re.I)
            if access and access.group(1).lower() not in ("private", "package", "public", "remote"):
                found.append((line, "access", "invalid access value " + access.group(1)))
        if name in ("cfif", "cfelseif", "cfset", "cfreturn"):
            symbol = SYMBOLS.search(STRING.sub(blank, rest))
            if symbol:
                found.append((line, "operators", "symbol operator " + symbol.group(0)))

    for match in re.finditer(r'<cffunction\b[^>]*?\bname\s*=\s*"(\w+)"', code, re.I):
        if re.match(r"equal(?!s_)|contains$", match.group(1), re.I):
            found.append((line_of(code, match.start()), "operator", "function name starts like an operator word: " + match.group(1)))
        if match.group(1).lower() in BUILTINS:
            found.append((line_of(code, match.start()), "builtin", "function named like a built-in: " + match.group(1)))

    for function in FUNCTION.finditer(code):
        body_started = False
        names = set()
        for match in TAG.finditer(function.group(0)):
            name, rest = match.group(2).lower(), match.group(3)
            if not match.group(1) and name == "cfargument":
                argument = re.search(r'\bname\s*=\s*"(\w+)"', rest, re.I)
                if argument:
                    names.add(argument.group(1).lower())
            if match.group(1) or name in ("cffunction", "cfargument"):
                continue
            is_var = name == "cfset" and re.match(r"\s+var\s", rest, re.I)
            if is_var:
                local = re.match(r"\s+var\s+(\w+)", rest, re.I)
                if local and local.group(1).lower() in names:
                    line = line_of(code, function.start() + match.start())
                    found.append((line, "dupvar", "local variable " + local.group(1) + " declared twice"))
                if local:
                    names.add(local.group(1).lower())
            if is_var and body_started:
                line = line_of(code, function.start() + match.start())
                found.append((line, "var", "var line after the first statement of the function"))
            if not is_var:
                body_started = True

    return found


def main():
    total = 0
    files = 0
    for folder in FOLDERS:
        for base, _, names in os.walk(os.path.join(ROOT, folder)):
            for name in sorted(names):
                full = os.path.join(base, name)
                rel = os.path.relpath(full, ROOT)
                if name.lower() == "application.cfc":
                    print("%s:1: appcfc: Application.cfc is ignored by the target server" % rel)
                    total += 1
                if not name.lower().endswith((".cfm", ".cfc")):
                    continue
                files += 1
                with open(full, "rb") as handle:
                    for line, rule, message in sorted(check(rel, handle.read())):
                        print("%s:%d: %s: %s" % (rel, line, rule, message))
                        total += 1
    print("%d files checked, %d problems" % (files, total))
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
