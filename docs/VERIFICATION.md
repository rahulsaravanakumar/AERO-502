# Verification record

## Sprint 2 (October 15, 2026)

All checks were run on `main` at `1f7fa94` (PR #25, the latest `main` as of this record). They ran in a clean clone, using the same commands as [CI](../.github/workflows/ci.yml).

| Item | Value |
| --- | --- |
| Environment | Ubuntu 24.04 (WSL2), Ruby 4.0.6, Bundler 4.0.16, PostgreSQL 16.15 |
| Run at | 2026-10-15 13:28 CDT |
| CI run for the same commit | [Actions run 38345995965](https://github.com/rahulsaravanakumar/AERO-502/actions/runs/38345995965): success, October 13, 2026 |

| Check | Command | Result |
| --- | --- | --- |
| Tests | `RAILS_ENV=test bin/rails db:test:prepare && bundle exec rspec` | **169 examples, 0 failures** (35.9 s) |
| Line coverage | SimpleCov (`script/coverage_summary.rb`) | **100% (630/630)** |
| Branch coverage | SimpleCov | **100% (159/159)** |
| Style | `bin/rubocop` | 96 files inspected, no offenses |
| Security scan | `bin/brakeman --no-pager` | Brakeman 8.1.0: 0 errors, 0 security warnings |
| JavaScript dependencies | `bin/importmap audit` | No vulnerable packages found |

Since Sprint 1: 45 → 169 examples, line coverage 216 → 630 lines (still 100%), branch coverage 96.15% → 100%.

### Results by story

☀ = normal use. ☂ = error, boundary, or unauthorized use. Every listed example passed in this run.

| Jira | Behavior checked | Expected result | Test | Actual |
| --- | --- | --- | --- | --- |
| KAN-19 | Leader builds Team › Subteam › Project | Records are saved and the parents are shown when reopened | ☀ [organization_management_spec.rb:21](../spec/requests/organization_management_spec.rb#L21) | Pass |
| KAN-19 | Missing name or parent | Refused, the field is identified, nothing is created | ☂ [organization_management_spec.rb:47](../spec/requests/organization_management_spec.rb#L47) | Pass |
| KAN-19 | Team A officer sends direct requests for Team B | Refused | ☂ [organization_management_spec.rb:106](../spec/requests/organization_management_spec.rb#L106) | Pass |
| KAN-19 | Archive a record | It leaves everyday lists; its tasks and hours stay viewable | ☀ [organization_management_spec.rb:75](../spec/requests/organization_management_spec.rb#L75) | Pass |
| KAN-20 | Assign/remove members, change status | Each change is recorded with who did it, newest first | ☀ [task_history_spec.rb:15](../spec/requests/task_history_spec.rb#L15), [:47](../spec/requests/task_history_spec.rb#L47) | Pass |
| KAN-20 | Member opens the history; anyone edits or deletes an event | Member does not see it; events cannot be changed | ☂ [task_history_spec.rb:71](../spec/requests/task_history_spec.rb#L71), [:84](../spec/requests/task_history_spec.rb#L84) | Pass |
| KAN-20 | Delete a task that has history or hours | Refused; history and hours are kept | ☂ [task_history_spec.rb:93](../spec/requests/task_history_spec.rb#L93) | Pass |
| KAN-21 | Search plus team and subteam filters | Only matching permitted tasks are shown | ☀ [task_search_filter_spec.rb:13](../spec/requests/task_search_filter_spec.rb#L13), [:25](../spec/requests/task_search_filter_spec.rb#L25) | Pass |
| KAN-21 | Search for another team's restricted task | Never shown | ☂ [task_search_filter_spec.rb:44](../spec/requests/task_search_filter_spec.rb#L44) | Pass |
| KAN-23 | Timeline bars | Each task's bar runs from start to due date, grouped by team and subteam | ☀ [timeline_spec.rb:11](../spec/requests/timeline_spec.rb#L11) | Pass |
| KAN-23 | Unreadable dates or window size | Falls back to the default 6-week window | ☂ [timeline_spec.rb:95](../spec/requests/timeline_spec.rb#L95) | Pass |
| KAN-23 | Member opens `/timeline` | Redirected; an officer sees only their own team | ☂ [timeline_spec.rb:110](../spec/requests/timeline_spec.rb#L110) | Pass |
| KAN-24 | Task estimate vs. actual hours | Task states the difference ("over/under estimate") | ☀ [planned_vs_actual_spec.rb:16](../spec/requests/planned_vs_actual_spec.rb#L16) | Pass |
| KAN-24 | Negative estimate | Rejected; zero is accepted | ☂ [planned_vs_actual_spec.rb:5](../spec/requests/planned_vs_actual_spec.rb#L5) | Pass |
| KAN-25 | Allowed email signs in with Google | Signed in with the assigned role and team, ignoring letter case | ☀ [google_sign_in_spec.rb:24](../spec/requests/google_sign_in_spec.rb#L24) | Pass |
| KAN-25 | Email not on the list, or not verified by Google | Refused with "Access not authorized" | ☂ [google_sign_in_spec.rb:32](../spec/requests/google_sign_in_spec.rb#L32) | Pass |
| KAN-25 | Person's access is removed | Signed out at their next page load; their tasks and hours are kept | ☂ [google_sign_in_spec.rb:80](../spec/requests/google_sign_in_spec.rb#L80) | Pass |
| KAN-29 | Board summary | Column counts, Overdue labels, leader hours table and chart | ☀ [board_summary_spec.rb:32](../spec/requests/board_summary_spec.rb#L32)–[:79](../spec/requests/board_summary_spec.rb#L79) (AC1–AC5) | Pass |
| KAN-29 | Reversed or unreadable hours date range | Error is shown; hours for all dates are displayed | ☂ [board_summary_spec.rb:94](../spec/requests/board_summary_spec.rb#L94) | Pass |
| KAN-17 | User guide | Linked from the header and sign-in page; opens without signing in | ☀ [user_guide_spec.rb:5](../spec/requests/user_guide_spec.rb#L5), [:14](../spec/requests/user_guide_spec.rb#L14) | Pass |
| KAN-17 | Every message the website shows | Explained in the guide with a next step | ☂ [user_guide_spec.rb:22](../spec/requests/user_guide_spec.rb#L22) | Pass |
| KAN-15 | Admin guide | Update, rollback, backup, and restore are numbered steps; no secret values | ☀ [admin_guide_spec.rb:35](../spec/docs/admin_guide_spec.rb#L35), ☂ [:24](../spec/docs/admin_guide_spec.rb#L24) | Pass |

Run one example with `bundle exec rspec <file>:<line>`. Run the whole suite with `bundle exec rspec --format documentation` to get a named result for every example.

### Known limitations and pending validation

- **KAN-26 (last Chief Engineer guard) is not on `main`.** PR #24 was merged into `dev` only, so it is not covered by this run or this deployment.
- **Google sign-in is tested with OmniAuth's test mode.** Real Google sign-in on Heroku depends on `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` and must be checked in the deployed app.
- **These are automated and local results, not customer acceptance.** Customer UAT for Sprint 2 is not yet recorded. KAN-16 and KAN-18 (training) have no recorded session.
- **Not implemented in Sprint 2:** KAN-22, 27, 28, 30, 31, 32, and 33.
- **Open Dependabot PRs** (pg, selenium-webdriver, simplecov, thruster, upload-artifact) are not merged. This run used the versions in `Gemfile.lock`.

## Sprint 1 (October 1, 2026)

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
