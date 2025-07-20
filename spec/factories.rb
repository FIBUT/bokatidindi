# frozen_string_literal: true

FactoryBot.define do
  factory :blockquote do
  end

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
    publisher          do
      Publisher.unscoped.order(Arel.sql('RANDOM()')).limit(1).first
    end
    original_title     { FFaker::Book.title }
    country_of_origin  { ['IS', 'US', 'JP', 'DE', 'FO', 'GL', 'FI'].sample }
    book_categories    { [association(:book_category, book: instance)] }
    book_authors       { [association(:book_author, book: instance)] }
    book_binding_types { [association(:book_binding_type, book: instance)] }
    book_editions      { [association(:book_edition, book: instance)] }

    trait :has_cover do
      after(:create) do |b|
        image_file_name = "book#{[1, 2, 3, 4, 5].sample}.jpg"
        image_contents = File.read(
          Rails.root.join("spec/assets/#{image_file_name}")
        )
        b.cover_image.attach(
          io: StringIO.new(image_contents),
          filename: "#{SecureRandom.uuid}.jpg"
        )
      end
    end
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

  factory :binding_type do
    name         { FFaker::Lorem.word }
    slug         { FFaker::Lorem }
    open         { true }
    group        { 'printed_books' }
    barcode_type { 'ISBN' }
  end

  factory :book_binding_type do
    barcode      { BookBindingType.unique_random_isbn }
    binding_type do
      BindingType.unscoped.where(
        group: 'printed_books',
        barcode_type: 'ISBN'
      ).order(
        Arel.sql('RANDOM()')
      ).take
    end
    page_count { FFaker::Number.number }
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
    firstname   { FFaker::Name.first_name }
    lastname    { FFaker::Name.last_name }
    added_by    { AdminUser.order(Arel.sql('RANDOM()')).limit(1).first }
  end

  factory :author_type do
    name      { FFaker::Job.title }
    rod       { FFaker::Random.rand(1..100) }
  end

  factory :edition do
    title        { "Bókatíðindi #{DateTime.now.year}" }
    opening_date { DateTime.now - 2.months }
    online_date  { DateTime.now - 1.month }
    closing_date { DateTime.now + 3.months }
    print_date   { DateTime.now + 3.months }
    year         { DateTime.now.year }

    online                      { true }
    open_to_web_registrations   { true }
    open_to_print_registrations { true }
  end

  factory :page do
    title { FFaker::Lorem.phrase.chop }
    body  { FFaker::Lorem.paragraph }
    slug  { FFaker::Internet.slug }
  end
end
