# Bókatíðindi

This codebase provides facilities for the following:

- The online edition of the Bokatidindi book journal
- Data entry for the online and print versions of the journal
- XML services for the print edition

## Licence

The source code published in this repository is published under the European
Union Public Licence (EUPL) version 1.2. You can view the full license text in
the [LICENCE](./LICENCE) file or at
https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12.

The licence does not cover any published information on bokatidindi.is, logos
etc, which are the intellectual property of FÍBÚT, its members or 3rd parties.

## Minimum Requirements

Bókatíðindi requires the following to work:

- Ruby 3.1.2
- Rails 7
- Postgres SQL
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
$ yarn install
$ yarn build 
$ rake db:create
$ rake db:schema:load # or rake db:migrate
$ rake db:seed
$ rake bt:attach_covers
```

## The production environment

We are currently hosting at Heroku. Our staging instance can be reached at
https://bokatidindi-staging.herokuapp.com/. Google Cloud Services is used for
static content and related services.

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

## ActiveJob and GoodJob

The system uses [GoodJob](https://github.com/bensheldon/good_job) for handling
background jobs; image processing in particular.

Setting the environment variable `JOB_EXECUTION_MODE` to `external` will enable
the GoodJob external processor, which runs in a separate worker dyno on Heroku
(defined in the Procfile). This should be done during high season, when we are
expecting a lot of incoming registrations.

During low season, the default value of `async` can be used. This enables us to
disable the worker dyno to save money on hosting, as the processing happens
asynchronously in the web server process. Note that the memory use may jump well
above 512 MB during image processing, so do make sure to tweak the
`GOOD_JOB_MAX_THREADS` environment variable to account for that.
