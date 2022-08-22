# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require Rails.root.join('spec/support/factory_bot.rb')
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:suite) do
    ['Innbundin', 'Gormabók', 'Harðspjaldabók'].each_with_index do |b, i|
      BindingType.create(
        source_id: i,
        name: b,
        rod: i + 1
      )
    end

    FactoryBot.create(:edition)

    FactoryBot.create_list :publisher, 200
    FactoryBot.create_list :author, 2000

    FactoryBot.create(:author_type, name: 'Höfundur')
    FactoryBot.create(:author_type, name: 'Þýðandi')
    FactoryBot.create(:author_type, name: 'Myndhöfundur')

    Category.create(
      source_id: 21, name: 'Skáldverk', group: :childrens_books, rod: 2
    )

    Category.create(
      source_id: 7, name: 'Fræði og bækur almenns efnis',
      group: :non_fiction, rod: 9
    )

    Category.create(
      source_id: 22, name: 'Fræðibækur',
      group: :childrens_books, rod: 3
    )

    Category.create(
      source_id: 23, name: 'Ungmennabækur',
      group: :childrens_books, rod: 4
    )

    Category.create(
      source_id: 5, name: 'Ljóð og leikrit',
      group: :fiction, rod: 7
    )

    Category.create(
      source_id: 20, name: 'Myndskreyttar 0 - 6 ára',
      group: :childrens_books, rod: 1
    )

    Category.create(
      source_id: 4, name: 'Þýdd skáldverk',
      group: :fiction, rod: 6
    )

    Category.create(
      source_id: 3, name: 'Íslensk skáldverk',
      group: :fiction, rod: 5
    )

    Category.create(
      source_id: 9, name: 'Ævisögur og endurminningar',
      group: :non_fiction, rod: 11
    )

    Category.create(
      source_id: 8, name: 'Saga, ættfræði og héraðslýsingar',
      group: :non_fiction, rod: 10
    )

    Category.create(
      source_id: 6, name: 'Listir og ljósmyndir',
      group: :non_fiction, rod: 8
    )

    50.times do
      book = FactoryBot.create(:book)
      FactoryBot.create(:book_author, book:)
      FactoryBot.create(:book_category, book:)
      FactoryBot.build(:book_binding_type, book:)
      FactoryBot.create(:book_edition, book:)

      image_file_name = "book#{[1, 2, 3, 4, 5].sample}.jpg"
      image_contents = File.read(
        Rails.root.join("spec/assets/#{image_file_name}")
      )
      book.attach_cover_image_from_string(image_contents)
    end
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end
