# Administration, update, and recovery guide

This guide covers the existing release and the Sprint 3 KAN-25 sign-in and access changes. Steps are numbered in the order they must be done. Use a practice copy of the website for training and recovery exercises. Never copy passwords, keys or secret values into this guide, chat, screenshots or recordings.

Keep a copy of this guide in an organization-owned location (for example the SAE AERO shared Google Drive) so leaders can open it after the student developers leave. The current version is also in the repository at `docs/ADMIN_GUIDE.md`.

## Ownership and support

Fill these in at each release and keep them up to date.

| Item | Where to find it |
| --- | --- |
| Application owner | The SAE AERO account that owns the Heroku app (Heroku dashboard → app → Access). |
| Website address | Heroku dashboard → app → Settings → Domains. |
| Hosting plan and cost | Heroku dashboard → app → Resources (dyno and Postgres plans) and Billing. Record the plan and monthly cost on the release date; prices change. |
| Support contact | The current Chief Engineer; the development team's contact until handover is complete. |
| Backup location | Heroku Postgres backups in the organization's Heroku app (`heroku pg:backups -a APP_NAME`), plus downloaded copies in the organization's shared drive. |
| Source code | `https://github.com/rahulsaravanakumar/AERO-502` |

## Configuration

Set these as Heroku Config Vars (Heroku dashboard → app → Settings → Reveal Config Vars). Never write their values anywhere else.

| Name | Purpose |
| --- | --- |
| `DATABASE_URL` | Database connection; Heroku Postgres sets it automatically. |
| `RAILS_MASTER_KEY` | Unlocks the application's encrypted credentials. |
| `GOOGLE_CLIENT_ID` | Google sign-in client ID from the organization's Google Cloud project. |
| `GOOGLE_CLIENT_SECRET` | Google sign-in client secret from the same project. |
| `PASSWORD_SIGN_IN` | Set to `off` once everyone signs in with Google; leave unset to keep practice password sign-in. |
| `DEMO_PASSWORD` | Password given to practice accounts when the practice data is seeded. |
| `RAILS_LOG_LEVEL` | Optional; how much detail the logs contain (default `info`). |

## Set up Google sign-in

Do this once, signed in to the organization's Google account. The current project is `aero-502` in the Google Cloud Console; give at least one organization officer the Owner role under IAM & Admin → IAM so it can be managed after the student developers leave.

1. Open the Google Cloud Console and create (or choose) a project owned by the organization.
2. Under Google Auth Platform → Branding, enter the app name and support email. Under Audience, choose Internal so only TAMU Google accounts can sign in.
3. Under Google Auth Platform → Clients, create an OAuth client of type Web application.
4. Add an authorized redirect URI for each website: `https://WEBSITE_ADDRESS/auth/google_oauth2/callback` for the live and practice websites, and `http://localhost:3000/auth/google_oauth2/callback` for developers. Changes can take a few minutes to apply.
5. Copy the client ID and secret into the Heroku Config Vars `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` on each website. Google shows a new secret only once; if it is lost, open the client, select **Add secret**, and replace the Config Var.
6. If nobody can sign in as Chief Engineer yet, add the first ones: `heroku run "bin/rails users:grant_chief_engineer EMAILS=first@tamu.edu,second@tamu.edu" -a APP_NAME`. It adds each email as a Chief Engineer (or promotes an existing person) and is safe to run again. Add everyone else under People.
7. Open the website and select **Sign in with Google** with an account already added under People. Choose the approved TAMU account in Google's account selector; no separate application password or password reset is needed.
8. Before turning off practice passwords, check approved Google sign-in for a Chief Engineer, an officer and a member on the deployed website. Confirm their assigned role, class (team) and subteam are unchanged. Also check an unlisted account is denied without showing project information. Automated tests mock Google; they do not prove that the deployed OAuth credentials and audience are configured correctly.

## People and access

Only people listed under **People** can sign in. Only the Chief Engineer can open this screen.

1. Sign in as the Chief Engineer and select **People**.
2. To approve a person, select **Add person**, enter their name and Google (TAMU) email, choose their role, team and subteam, and select **Add person** to save. They can sign in with Google immediately, without a separate password or invitation. Email matching ignores capitalization; adding `JDoe@tamu.edu` also approves `jdoe@tamu.edu`. Class is labeled **Team** in the application. Select a subteam belonging to that team.
3. To change a person's role, team or subteam, select **Change role** next to their name, make the change and select **Save role**. It takes effect the next time they load a page.
4. To remove a person's access, select **Remove access** next to their name. They are signed out at their next page load or submitted action, including a form they opened before removal, and cannot sign in. Their saved tasks, assignments and hours are kept; do not delete their records to remove access.
5. To let them back in, select **Restore access**. They can use their approved Google account again.

Officers and members have no People navigation or access-management controls. Direct requests to People or its add, edit, remove and restore actions are denied by the server. Google supplies proof of email ownership; the application's saved role, class and subteam determine access.

If sign-in is denied, compare the selected Google email with the saved People entry and check whether it says **Access removed**. Choose the approved Google account or restore access as appropriate. A rejected or cancelled Google sign-in ends the previous application session; selecting an approved account starts a new one.

The website blocks changing the last active Chief Engineer to another role or removing their access, including direct requests. A Chief Engineer whose access has already been removed does not count as an active administrator. Add another active Chief Engineer before removing the outgoing chief's role or access.

### Semester handover

1. The outgoing Chief Engineer adds each incoming chief under People (or changes their role) to Chief Engineer.
2. The incoming chief signs in and confirms they can open People.
3. The incoming chief removes access for, or changes the role of, outgoing leaders.

## First-time organization setup

Seeding loads **practice data only**: the three classes (Regular, Micro, Advanced), their subteams, starter projects, practice accounts and practice tasks. Use it for a practice website, not for real members.

1. Create a database backup (see below) if the database already holds records.
2. Run `heroku run bin/rails db:seed -a APP_NAME`.
3. Sign in with a practice account from `docs/TRAINING_GUIDE.md` and check that **Teams** lists the three classes with their subteams and projects.

For the live website, enter the agreed real structure through the Teams screen instead (next section). Real member records are not imported unless the customer approves a separate transfer plan.

## Managing teams, subteams and projects

Each class (team) has subteams, and each subteam has projects. Every task belongs to a project.

1. Select **Teams**.
2. The Chief Engineer selects **New team** to add a class.
3. Select **Add subteam** under a team, enter the name and select **Save subteam**.
4. Select **Add project** under a subteam, enter the name and select **Save project**.
5. Select **Rename** to change a name. A subteam stays in its team and a project stays in its subteam.
6. Select **Archive** to remove a group from everyday lists. Its tasks and hours are kept: select it under **Archived** to see them, or select **Restore** to bring it back.

The Chief Engineer manages every team. Officers add, rename and archive subteams and projects in their own team only.

## Routine administration

1. Confirm the website's health check at `/up` returns success.
2. Review failed GitHub Actions checks before merging. Each run's test job summary shows test coverage.
3. Manage people under **People** and groups under **Teams** (see above).
4. Give the Chief Engineer role only to organization-authorized maintainers.
5. Before a release, create a database backup and record the deployed Git commit.

## Update procedure

1. Confirm tests, RuboCop and Brakeman pass on the intended release commit.
2. Create a database backup in the organization's Heroku account. This release reorganizes projects under subteams; that database change cannot be undone except by restoring this backup.
3. Deploy the reviewed commit. The Procfile release phase runs database migrations.
4. Open `/up`, sign in, and check one task, one status update, the board's Hours by member section and the Teams screen.
5. Record the commit SHA, time, operator, backup identifier and result.

## Simulated failed update and rollback

1. Stop and do not run further migrations after detecting a failed release.
2. In Heroku, find the last known-good release under Activity.
3. Roll back with the Heroku dashboard or `heroku releases:rollback vNN -a APP_NAME`.
4. If the failed release changed the database, restore the pre-release backup (next section) on the practice website first, then on the live website.
5. Open `/up` and repeat the update checks.
6. Record the failure, the recovery action and the outcome.

## Database backup and restore

1. Capture a backup: `heroku pg:backups:capture -a APP_NAME`.
2. Note the backup identifier shown (for example `b012`) and download a copy: `heroku pg:backups:download b012 -a APP_NAME`.
3. Store the downloaded file in the organization's shared drive.
4. To restore, confirm you are targeting the right app and backup, then run `heroku pg:backups:restore b012 DATABASE_URL -a APP_NAME --confirm APP_NAME`.
5. Sign in and confirm the agreed practice records are present.

A restore replaces the whole database: all changes made after the backup are lost, including new tasks, hours, people and history. Practice restores only on the practice website.
