# Bókatíðindi

- Ruby 3.1.2
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
$ rvm install 3.1.2
$ rvm use 3.1.2
$ bundle install
$ rake yarn:install
$ rake db:create
$ rake db:schema:load # or rake db:migrate
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
$ heroku run:detached --size standard-2x rake bt:attach_covers
```

### Seeds

#### Seeding from a nightly dump

We are currently loading the data from a nighyly MySQL dump, into our own MySQL
instance and into Postgres for development and production, the following is the
way we create seeds for the production environment.

We expect this to be a stop-gap measure until we can ingress the data from
FÍBÚT's database, but let's not get our hopes up.

The following reads the data from FÍBÚT's database and into our
development database:

```
$ SEED_FROM=mysql rake db:seed
```

Note that you may need to set the following environment variables to do this
successfully:

* `BOKATIDINDI_EDITION` (defaults to `BT2021`)
* `MYSQL_HOST` (defaults to `localhost`),
* `MYSQL_DATABASE` (defaults to `bokatidindi-source`)
* `MYSQL_USERNAME` (defaults to `root`)
* `MYSQL_PASSWORD` (defaults to `root`)
* `SKIP_DUMP` (If set, the rake task will skip downloading the nightly dump and go straight into seeding Postgres)

#### Seeding from a local Postgres dump

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

In case the cover images have not been attached, the `<img>` tags for each will
refer to the original cover images from that storage bucket. Those can be a
couple of megabytes in size, so it may be much better to run the above rake task
each time new data arrives or an environment is initialised.

For production:

```
$ heroku run:detached --size standard-2x rake bt:attach_covers
```

For development:

```
$ rake bt:attach_covers
```

In the development environemnt, the different variants of each book cover are
stored using the local environment. In production, we use a second GCS storage
bucket (`gs://bokatidindi-staging-bucket`) in combination with a GCS CDN service
to store and serve the same data.

Another difference between the production and local environments is that in the
production environment, we need to preprocess all the different cover image
variants for the CDN, while in the development environemnt, those will be
generated on the fly. This means that running this in production can be expexted
to take a couple of hours and should be avoided during.
