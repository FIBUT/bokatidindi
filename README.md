# Bókatíðindi

- Ruby 2.7.4
- Rails 6
- Postgres (production)
- SQLite (development)
- MySQL (for database dumps from FÍBÚT)

## The development environment.

- To simplify the local development efforts, we are sticking with SQLite.
- Run the local web server using `rails s`. You can stop it using `ctrl-c` at any time.

### Setting the environment up using RVM

```
$ rvm install 2.7.4
$ rvm use 2.7.4
$ bundle install
$ rake yarn:install
```

## The production environment

We are currently hosting at Heroku. Our staging instance can be reached at
http://127.0.0.1:3000/. We are using a Postgres database there, which may behave
differently from SQLite.

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

As we are currently loading the data from MySQL and into SQLite locally for
development, the following is the way we create seeds for the production
environment:

```
$ rake db:seed:dump MODELS=category,publisher,author,author_type,binding_type,book,book_category,book_author,book_binding_type FILE=db/seeds/from_dev_data.rb
```

We intend to connect directly with FÍBÚT's database, but as of now we need to
rely on those daily dumps.
