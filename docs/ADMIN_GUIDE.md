# Administration, update, and recovery guide

Use a practice copy for training and recovery exercises. Never copy production passwords into this guide, chat, screenshots, or recordings.

## Routine administration

1. Confirm the application health endpoint returns success at `/up`.
2. Review failed GitHub Actions checks before merging.
3. Add or update authorized users through a reviewed seed/migration or the Rails console.
4. Give Chief Engineer access only to organization-authorized maintainers.
5. Before a release, create a database backup and record the deployed Git commit.

## Update procedure

1. Confirm tests, RuboCop, and Brakeman pass on the intended release commit.
2. Create a database backup in the organization's Heroku account.
3. Deploy the reviewed commit. The Procfile release phase runs migrations.
4. Check `/up`, sign in with a practice account, and verify one task, one status update, and the dashboard.
5. Record the commit SHA, time, operator, backup identifier, and verification result.

## Simulated failed update and rollback

1. Stop and do not run additional migrations after detecting a failed release.
2. In Heroku, locate the last known-good release.
3. Roll back to that release using the dashboard or `heroku releases:rollback vNN -a APP_NAME`.
4. Check `/up` and repeat the smoke test.
5. If the migration changed data incompatibly, restore the pre-release backup into the practice app before touching production.
6. Document the failure, recovery action, and outcome.

## Database backup and restore

Create and download a backup:

```sh
heroku pg:backups:capture -a APP_NAME
heroku pg:backups:download -a APP_NAME
```

Restore only after verifying the target app and backup identifier:

```sh
heroku pg:backups:restore BACKUP_URL DATABASE_URL -a PRACTICE_APP_NAME
```

A restore replaces target database contents. Perform the recovery exercise only against the approved practice application, then confirm agreed practice records remain available.
