release: rake db:migrate && rake assets:clobber && rake assets:precompile && rake bt:maintain_collation && rake bt:update_category_counters
web: bundle exec puma -C config/puma.rb