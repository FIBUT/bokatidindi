# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user_publisher do
    admin_user_id { 1 }
    publisher_id { 1 }
  end

  factory :admin_user do
    name                  { FFaker::Name.name }
    email                 { FFaker::Internet.email }
    role                  { AdminUser.roles[:admin] }
    password              { 'password123456' }
    password_confirmation { 'password123456' }

    factory :publisher_user do
      role { AdminUser.roles[:publisher] }
    end
  end

  factory :book do
    pre_title          { ['', '', '', FFaker::Book.title].sample }
    title              { FFaker::Book.title }
    post_title         { ['', '', '', FFaker::Book.title].sample }
    description        { FFaker::Lorem.paragraph }
    long_description   { FFaker::Lorem.paragraphs(4).join("\n\n") }
    publisher          { Publisher.order(Arel.sql('RANDOM()')).limit(1).first }
    original_title     { FFaker::Book.title }
    country_of_origin  { ['IS', 'US', 'JP', 'DE', 'FO', 'GL', 'FI'].sample }
    book_categories    { [association(:book_category, book: instance)] }
    book_authors       { [association(:book_author, book: instance)] }
    book_binding_types { [association(:book_binding_type, book: instance)] }
    book_editions      { [association(:book_edition, book: instance)] }
  end

  factory :book_category do
    category { Category.order(Arel.sql('RANDOM()')).limit(1).first }
    book
  end

  factory :book_author do
    book
    author { Author.order(Arel.sql('RANDOM()')).limit(1).first }
    author_type { AuthorType.first }
  end

  factory :book_binding_type do
    barcode      { BookBindingType.random_isbn }
    binding_type { BindingType.first }
    page_count   { FFaker::Number.number }
    book
  end

  factory :book_edition do
    book
    edition { Edition.first }
  end

  factory :publisher do
    source_id { FFaker::Random.rand(1..999_999_999) }
    name      { FFaker::Company.unique.name }
    url       { FFaker::Internet.http_url }
  end

  factory :author do
    source_id { FFaker::Random.rand(1..999_999_999) }
    firstname { FFaker::Name.first_name }
    lastname  { FFaker::Name.last_name }
  end

  factory :author_type do
    source_id { FFaker::Random.rand(1..999_999_999) }
    name      { FFaker::Job.title }
    rod       { FFaker::Random.rand(1..100) }
  end

  factory :edition do
    title        { FFaker::Lorem.phrase.chop }
    opening_date { DateTime.now - 2.months }
    online_date  { DateTime.now - 1.month }
    closing_date { DateTime.now + 3.months }
    print_date   { DateTime.now + 3.months }
  end
end
