# Heroku deployment guide

Canvas requires the Sprint 1 increment in the customer's Heroku account. Deployment ownership and billing must remain with the organization.

## First deployment

1. Have the Chief Engineer or authorized organization owner create the Heroku application.
2. Add Heroku Postgres to the application.
3. Add the GitHub repository as the deployment source, or add the Heroku Git remote.
4. Set `RAILS_MASTER_KEY` from `config/master.key` through Heroku Config Vars. Do not commit or paste it into documentation.
5. Set `DEMO_PASSWORD` to an approved practice password shared separately with testers.
6. Deploy the reviewed `main` commit. The `release` Procfile command runs `bin/rails db:migrate`.
7. Run `heroku run bin/rails db:seed -a APP_NAME` for agreed practice records.
8. Open `https://APP_NAME.herokuapp.com/up`, then perform the role and task smoke tests.
9. Record the application URL, commit SHA, Heroku owner, add-ons, and current recurring price in the project notebook.

Pricing changes over time. Capture the active plan and recurring cost from the organization's Heroku dashboard at submission time; do not rely on an old price copied into this repository.

## Required environment

- Ruby 4.0.6
- PostgreSQL through `DATABASE_URL`
- `RAILS_MASTER_KEY`
- Optional `DEMO_PASSWORD`

## Data decision

The seed file contains practice records only. Importing real organization records is not part of Sprint 1 unless the customer explicitly approves a separate transfer plan.
