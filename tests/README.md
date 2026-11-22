# Tests

Plain Python 3 with no packages to install.

## Static checks

```
python3 tests/lint.py
```

Reads every `.cfm` and `.cfc` file under `app`, `system`, `public` and `tests` and reports the rules
that can be seen without a server: ASCII only, no script blocks, `output="no"` on every component and
function, word operators only, `var` lines first in a function, no `Application.cfc`.

This runs on GitHub for every pull request (`.github/workflows/lint.yml`).
