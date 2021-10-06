# Generating production seeds

`$ rake db:seed:dump MODELS=category,publisher,author,author_type,binding_type,book,book_category,book_author,book_binding_type FILE=db/seeds/from_dev_data.rb`

# Deployment

`$ git push heroku main`