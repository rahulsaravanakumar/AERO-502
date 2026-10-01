# Sprint 1 verification record

Sprint 1 delivery checks verified locally on October 1, 2026 against PostgreSQL.

| Check | Result |
| --- | --- |
| `bundle exec rspec` | 45 examples, 0 failures |
| SimpleCov line coverage | 100% (216/216), enforced by the test suite |
| SimpleCov branch coverage | 96.15% (50/52) |
| `bin/rubocop` | 55 files inspected, no offenses |
| `bin/brakeman --no-pager` | Brakeman 8.1.0: 0 errors, 0 security warnings |

Model specs: [Task](../spec/models/task_spec.rb), [User](../spec/models/user_spec.rb), [TimeEntry](../spec/models/time_entry_spec.rb).
Request specs: [Sprint 1 workflow](../spec/requests/sprint_one_workflow_spec.rb), [Task management](../spec/requests/task_management_spec.rb).
Delivery regressions: [Task cards](../spec/requests/task_card_delivery_spec.rb), [Access and status](../spec/requests/access_status_delivery_spec.rb), [Hours and totals](../spec/requests/effort_delivery_spec.rb), [Health](../spec/requests/health_delivery_spec.rb).

Browser verification found that the hours input's `min="0.01"` and `step="0.25"` rejected ordinary entries such as 1.5 hours. Changed the step to 0.01 and added a regression for the rendered input. Retested locally: submitting 1.5 hours succeeded and changed the task's actual total from 2.5 to 4 hours.
Run `bundle exec rspec` for named results and `coverage/index.html`. CI publishes the report as the `rspec-coverage` artifact. Each run measures RSpec alone; previous Minitest results are not merged.

The notebook PDF's older test screenshots predate this migration. Use this record and the new CI evidence for the corrected test setup.

Earlier checks from September 27, 2026 (not rerun as part of the test-framework migration):

| Check | Result |
| --- | --- |
| `bin/importmap audit` | No vulnerable packages found |
| Browser smoke test | Member sign-in, scoped dashboard, task details, status form, hour form, planned/actual totals rendered successfully |

These are local verification results, not deployed UAT acceptance. Repeat the commands on the exact commit deployed to Heroku and attach the CI run plus deployed browser/UAT evidence to the notebook.
