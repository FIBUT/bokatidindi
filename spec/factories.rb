# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    name                  { FFaker::Name.name }
    email                 { FFaker::Internet.email }
    role                  { AdminUser.roles[:admin] }
    password              { 'password123456' }
    password_confirmation { 'password123456' }

    factory :publisher_user do
      role      { AdminUser.roles[:publisher] }
      publisher { Publisher.order(Arel.sql('RANDOM()')).limit(1).first }
    end
  end

  factory :book do
    source_id        { FFaker::Random.rand(1..999_999_999) }
    pre_title        { '' }
    title            { FFaker::Lorem.phrase.chop }
    post_title       { '' }
    description      { FFaker::Lorem.paragraph }
    long_description { FFaker::Lorem.paragraphs(4).join("\n\n") }
    page_count       { FFaker::Random.rand(20..200) }
    publisher        { Publisher.order(Arel.sql('RANDOM()')).limit(1).first }
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
    barcode      { Faker::Code.ean }
    binding_type { BindingType.first }
    book
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
    title { FFaker::Lorem.phrase.chop }
    original_title_id_string { FFaker::Lorem.characters(7) }
    active { false }
  end
end
