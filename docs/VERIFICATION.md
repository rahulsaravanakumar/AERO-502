# Sprint 1 verification record

Verified locally on September 27, 2026 against PostgreSQL 18.6.

| Check | Result |
| --- | --- |
| `bin/rails test` | 17 runs, 65 assertions, 0 failures, 0 errors, 0 skips |
| SimpleCov line coverage | 82.40% (178/216) |
| SimpleCov branch coverage | 51.92% (27/52) |
| `bin/rubocop` | 54 files inspected, no offenses |
| `bin/brakeman --no-pager` | 0 errors, 0 security warnings |
| `bin/importmap audit` | No vulnerable packages found |
| Browser smoke test | Member sign-in, scoped dashboard, task details, status form, hour form, planned/actual totals rendered successfully |

These are local verification results, not deployed UAT acceptance. Repeat the commands on the exact commit deployed to Heroku and attach the CI run plus deployed browser/UAT evidence to the notebook.
