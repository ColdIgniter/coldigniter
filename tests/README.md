# Tests

Two kinds of test, both plain Python 3 with no packages to install.

## Static checks

```
python3 tests/lint.py
```

Reads every `.cfm` and `.cfc` file under `app`, `system`, `public` and `tests` and reports the rules
that can be seen without a server: ASCII only, no script blocks, `output="no"` on every component and
function, word operators only, `var` lines first in a function, no `Application.cfc`.

This runs on GitHub for every pull request (`.github/workflows/lint.yml`).

## Request tests on a real server

```
python3 tests/box/run.py
```

Nothing proves that the code runs on ColdFusion MX 6.1 except the server itself. The runner uploads a
scratch copy of `app`, `system` and `writable` over FTP, next to the real site, puts the files of
`tests/_support` on top of it (a test controller, its routes and a view), makes the requests listed in
`tests/box/cases.py`, compares status, body and headers, and removes the scratch copy again.

It needs a server that it can reach and an FTP account whose root is the folder that holds `app`,
`system` and `public`:

- `COLDIGNITER_TEST_HOST`: the site, default `coldigniter.lan`.
- `COLDIGNITER_TEST_TAG`: suffix of the scratch folders, default `ci`. Two runs at the same time need
  different tags.
- The FTP user and password come from `~/.netrc`, under `machine <host>`.

`--keep` leaves the scratch copy on the server to look at (`/_t<tag>/index.cfm?/some/route`), and
`--clean` removes one that was left behind.

GitHub's own runners cannot reach a server on a private network, so these tests do not run on GitHub
unless a self-hosted runner is added on a machine that can reach the server.

## Adding a test

Add a route to `tests/_support/app/Config/Routes.local.cfm`, a method to
`tests/_support/app/Controllers/Test.cfc` when one is needed, and a case to `tests/box/cases.py`.
