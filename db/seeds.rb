# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts '👤 Creating Admin User'
AdminUser.create(
  email: 'admin@example.com',
  name: 'admin',
  role: 'admin',
  password: 'password',
  password_confirmation: 'password'
)

puts "📁 Creating Categories"
FactoryBot.create(:edition)

Category.create name: 'Skáldverk',
                description: FFaker::Lorem.sentence,
                group: :childrens_books,
                rod: 2

Category.create name: 'Fræði og bækur almenns efnis',
                description: FFaker::Lorem.sentence,
                group: :non_fiction,
                rod: 9

Category.create name: 'Fræðibækur',
                description: FFaker::Lorem.sentence,
                group: :childrens_books,
                rod: 3

Category.create name: 'Ungmennabækur',
                description: FFaker::Lorem.sentence,
                group: :childrens_books,
                rod: 4

Category.create name: 'Ljóð og leikrit',
                description: FFaker::Lorem.sentence,
                group: :fiction,
                rod: 7

Category.create name: 'Myndskreyttar 0 - 6 ára',
                description: FFaker::Lorem.sentence,
                group: :childrens_books,
                rod: 1

Category.create name: 'Þýdd skáldverk',
                description: FFaker::Lorem.sentence,
                group: :fiction,
                rod: 6

Category.create name: 'Íslensk skáldverk',
                description: FFaker::Lorem.sentence,
                group: :fiction,
                rod: 5

Category.create name: 'Ævisögur og endurminningar',
                description: FFaker::Lorem.sentence,
                group: :non_fiction,
                rod: 11

Category.create name: 'Saga, ættfræði og héraðslýsingar',
                description: FFaker::Lorem.sentence,
                group: :non_fiction,
                rod: 10

Category.create name: 'Listir og ljósmyndir',
                description: FFaker::Lorem.sentence,
                group: :non_fiction,
                rod: 8

puts '🖊️ Creating Author Types'
FactoryBot.create(:author_type, name: 'Höfundur', abbreviation: 'Höf')
FactoryBot.create(:author_type, name: 'Þýðandi', abbreviation: 'Þýð')
FactoryBot.create(:author_type, name: 'Myndhöfundur', abbreviation: 'Myndh')

puts '📚 Creating Binding Types'
BindingType.create(name: 'Innbundin', rod: 1, open: true, barcode_type: 'ISBN')
BindingType.create(name: 'Kilja', rod: 1, open: true, barcode_type: 'ISBN')
BindingType.create(name: 'Tímarit', rod: 1, open: true, barcode_type: 'ISSN')

puts '🧑‍💼 Creating Publishers'
publishers_progressbar = ProgressBar.create(total: 50)
50.times do
  FactoryBot.create :publisher
  publishers_progressbar.increment
end

puts '🖊️ Creating Authors'
authors_progressbar = ProgressBar.create(total: 200)
200.times do
  FactoryBot.create :author
  authors_progressbar.increment
end

puts '📘 Creating books'
books_progressbar = ProgressBar.create(total: 600)
600.times do
  FactoryBot.create :book, :has_cover
  books_progressbar.increment
end

puts '#️ Updating Category Counts'
Category.update_all_counts

%i[forsida um_bokatidindi argangar open_data privacy_policy].each do |slug|
  FactoryBot.create(:page, slug: slug)
end
