# Bókatíðindi

- Ruby 2.7.4
- Rails 6
- Postgres
- MySQL (for database dumps from FÍBÚT)

## The development environment.

- To simplify the local development efforts, we are sticking with SQLite.
- Run the local web server using `rails s`. You can stop it using `ctrl-c` at any time.

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
```

## The production environment

We are currently hosting at Heroku. Our staging instance can be reached at
https://bokatidindi-staging.herokuapp.com/. We are using a Postgres database
there, which may behave differently from SQLite.

### Deployment

```
$ git push heroku main
```

### Resetting the production database

```
$ heroku pg:reset DATABASE --confirm bokatidindi-staging
$ heroku run rake db:schema:load
$ heroku run rake db:seed
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
$ rake db:seed:dump MODELS=category,publisher,author,author_type,binding_type,book,book_category,book_author,book_binding_type FILE=db/seeds/from_dev_data.rb
```

To deploy the seeded data into the production database, commit the changes to
'main':

```
$ git commit db/seeds/from_dev_data.rb -m "Updating seeds"
$ git push heroku main
```

Then follow the instructions under "Resetting the production database".
