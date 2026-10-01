# Sprint 1 quality strategy

## Compliance

- Sprint 1 implementation is traced to KAN-6 through KAN-18 and KAN-24 in `SPRINT1_EVIDENCE.md`.
- Role and team boundaries are enforced in controllers and model scopes, not only hidden in the interface.
- The repository follows the team's five-space Ruby indentation rule and Rails naming conventions.
- Submission claims must reference the approved scope, data design, and UAT rather than older templates.

## Correctness

- Model tests cover estimates, hours, assignments, totals, variance, email normalization, and roles.
- Integration tests exercise sign-in, direct-URL denial, status changes, time logging, and officer task creation.
- PostgreSQL constraints and unique indexes protect email addresses, names within parents, and duplicate assignments.
- Seeded practice data implements the UAT's 10 estimated hours and 4+3 actual-hour scenario.

## Integrity

- Passwords use `has_secure_password`/bcrypt; plaintext passwords are not stored.
- CSRF protection and encrypted Rails sessions are enabled by default.
- Strong parameters permit only expected fields.
- Members cannot fetch unassigned tasks, and officers cannot manage another team's tasks.
- Brakeman and dependency audits are part of CI.

## Usability

- Visible labels, fieldsets, skip link, keyboard-sized controls, focus outlines, semantic tables, and live alert/status roles support keyboard and assistive-technology use.
- Empty boards explain that no tasks are available.
- Errors preserve the last valid database value and explain correction.
- The responsive board collapses to one column on narrow screens.
- Written user steps do not depend on screenshots alone.

## Maintainability

- Controllers coordinate requests while models own validation, relationships, totals, and access scopes.
- Reusable partials and centralized CSS avoid duplicated form and layout logic.
- Migrations, seeds, health endpoint, CI, deployment, backup, rollback, and training instructions are versioned with the code.
- RSpec runs model and request specs; SimpleCov enforces 100% line coverage.
