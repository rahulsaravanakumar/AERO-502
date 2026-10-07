# AERO Task Hub

A Vivify Scrum-style, role-aware task and effort tracker for the SAE AERO Design team. Sprint 1 provides authentication, task cards and assignments, member status updates, actual-hour logging, and a meeting-ready planned-versus-actual dashboard.

## Sprint 1 capabilities

- Chief Engineers can view and manage every team's work.
- Officers can create, assign, and edit tasks only for their own team.
- Members can see only assigned work, update its status, and log their own hours.
- Task cards capture deliverables, work instructions, links, due dates, estimates, status, and multiple assignees.
- Dashboards show assignments, statuses, estimated hours, actual hours, variance, and member totals.
- Server-side authorization protects direct URLs as well as navigation.

## Local setup

Requirements: Ruby 4.0.6, Rails 8.1, PostgreSQL, and Bundler 4.0.16.

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

Open http://localhost:3000. The practice password defaults to `AeroSprint1!` and can be overridden with `DEMO_PASSWORD`. Practice emails are listed in `docs/TRAINING_GUIDE.md`.

## Verification

```sh
bundle exec rspec
bin/rubocop
bin/brakeman --no-pager
```

SimpleCov enforces 100% line coverage. GitHub Actions runs RSpec with PostgreSQL, RuboCop, Brakeman, and the import-map audit.

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [Administration, update, and recovery](docs/ADMIN_GUIDE.md)
- [Deployment guide](docs/DEPLOYMENT.md)
- [Training checklist](docs/TRAINING_GUIDE.md)
- [Sprint 1 traceability and evidence](docs/SPRINT1_EVIDENCE.md)
- [Five-aspect quality strategy](docs/QUALITY_STRATEGY.md)
- [Verification results](docs/VERIFICATION.md)
- [Canvas submission checklist](docs/SUBMISSION_CHECKLIST.md)
