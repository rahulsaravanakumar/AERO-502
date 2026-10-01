# Sprint 1 verification record

RSpec migration verified locally on October 1, 2026 against PostgreSQL.

| Check | Result |
| --- | --- |
| `bundle exec rspec` | 27 examples, 0 failures |
| SimpleCov line coverage | 100% (216/216), enforced by the test suite |
| SimpleCov branch coverage | 96.15% (50/52) |
| `bin/rubocop` | 51 files inspected, no offenses |

Model specs: [Task](../spec/models/task_spec.rb), [User](../spec/models/user_spec.rb), [TimeEntry](../spec/models/time_entry_spec.rb).
Request specs: [Sprint 1 workflow](../spec/requests/sprint_one_workflow_spec.rb), [Task management](../spec/requests/task_management_spec.rb).
Run `bundle exec rspec` for named results and `coverage/index.html`. CI publishes the report as the `rspec-coverage` artifact. Each run measures RSpec alone; previous Minitest results are not merged.

The notebook PDF's older test screenshots predate this migration. Use this record and the new CI evidence for the corrected test setup.

Earlier checks from September 27, 2026 (not rerun as part of the test-framework migration):

| Check | Result |
| --- | --- |
| `bin/brakeman --no-pager` | 0 errors, 0 security warnings |
| `bin/importmap audit` | No vulnerable packages found |
| Browser smoke test | Member sign-in, scoped dashboard, task details, status form, hour form, planned/actual totals rendered successfully |

These are local verification results, not deployed UAT acceptance. Repeat the commands on the exact commit deployed to Heroku and attach the CI run plus deployed browser/UAT evidence to the notebook.
