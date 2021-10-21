# Bókatíðindi

- Ruby 2.7.4
- Rails 6
- Postgres
- MySQL (for database dumps from FÍBÚT)

## The development environment.

- Run the local web server using `rails s`. You can stop it using `ctrl-c` at any time.
- Push and checkout code regularly.
- Do (`git fetch --all` and `git rebase master`) if you are working on a single branch for too long.
- In case there are database updates, make sure to run `rake db:migrate` every time you checkout from the main branch.

### Setting up Postges

Install the Postgres database server with `brew install postgresql` (Mac) or
use your Linux package manager.

```
# Log in as the Postgres user.
$ sudo -i -u postgres

# Create a Postgres user role for yourself.
# Type in your username as the "name of role" (i.e. hallakol or aldavigdis).
# Answer any question with 'y'.
$ createuser --interactive

# Exit the sudo session
$ exit
```

### Setting the environment up using RVM

```
$ rvm install 2.7.4
$ rvm use 2.7.4
$ bundle install
$ rake yarn:install
$ rake db:create
$ rake db:schema:load
$ rake db:seed
$ rake bokatidindi:attach_cover_image
```

## The production environment

We are currently hosting at Heroku. Our staging instance can be reached at
https://bokatidindi-staging.herokuapp.com/.

### Deployment

```
$ git push heroku main
```

### Resetting the production database

```
$ heroku pg:reset DATABASE --confirm bokatidindi-staging
$ heroku run rake db:schema:load
$ heroku run rake db:seed
$ heroku run rake bokatidindi:attach_cover_image
```

### Generating production seeds

We are currently loading the data from MySQL and into Postgres for development
and production, the following is the way we create seeds for the production
environment.

We expect this to be a stop-gap measure until we can ingress the data from
FÍBÚT's database, but let's not get our hopes up.

The following reads the data from a local MySQL database and into our
development database:

```
$ SEED_FROM=mysql rake db:seed
```

This generates a seed file based on the ingressed data:

```
pg_dump -T active_storage* -T schema_migrations -T ar_internal_metadata -a bokatidindi_development > db/seeds/development.sql
```

To deploy the seeded data into the production database, commit the changes to
'main':

```
$ git commit db/seeds/development.sql -m "Updating seeds"
$ git push heroku main
```

Then follow the instructions under "Resetting the production database".

## Rake Tasks

### Attaching a book cover to each book

Each book should has a cover image attached using ActiveStorage. We feed those
book covers into both the development and production instances from a Google
Cloud Services storage bucket (`gs://bokatidindi-covers-original`).

```
$ rake bokatidindi:attach_cover_image
```

In case the cover images have not been attached, the `<img>` tags for each will
refer to the original cover images from that storage bucket. Those can be a
couple of megabytes in size, so it may be much better to run the above rake task
each time new data arrives or an environment is initialised.

In the development environemnt, the different variants of each book cover are
stored using the local environment. In production, we use a second GCS bucket
(`gs://bokatidindi-staging-bucket`) to store and serve the same data.
