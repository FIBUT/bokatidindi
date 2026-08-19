release: rake db:migrate && rake bt:maintain_collation && rake bt:update_category_counters && rake assets:precompile
web: bundle exec puma -C config/puma.rb
worker: good_job start
