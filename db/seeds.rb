# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

AdminUser.create(
  email: 'admin@example.com',
  name: 'admin',
  role: 'admin',
  password: 'password',
  password_confirmation: 'password'
)

FactoryBot.create(:edition)

Category.create(name: 'Skáldverk', group: :childrens_books, rod: 2)
Category.create(name: 'Fræði og bækur almenns efnis', group: :non_fiction, rod: 9)
Category.create(name: 'Fræðibækur', group: :childrens_books, rod: 3)
Category.create(name: 'Ungmennabækur', group: :childrens_books, rod: 4)
Category.create(name: 'Ljóð og leikrit', group: :fiction, rod: 7)
Category.create(name: 'Myndskreyttar 0 - 6 ára', group: :childrens_books, rod: 1)
Category.create(name: 'Þýdd skáldverk', group: :fiction, rod: 6)
Category.create(name: 'Íslensk skáldverk', group: :fiction, rod: 5)
Category.create(name: 'Ævisögur og endurminningar', group: :non_fiction, rod: 11)
Category.create(name: 'Saga, ættfræði og héraðslýsingar', group: :non_fiction, rod: 10)
Category.create(name: 'Listir og ljósmyndir', group: :non_fiction, rod: 8)

FactoryBot.create(:author_type, name: 'Höfundur', abbreviation: 'Höf')
FactoryBot.create(:author_type, name: 'Þýðandi', abbreviation: 'Þýð')
FactoryBot.create(:author_type, name: 'Myndhöfundur', abbreviation: 'Myndh')

BindingType.create(name: 'Innbundin', rod: 1, open: true, barcode_type: 'ISBN')
BindingType.create(name: 'Kilja', rod: 1, open: true, barcode_type: 'ISBN')
BindingType.create(name: 'Tímarit', rod: 1, open: true, barcode_type: 'ISSN')

FactoryBot.create_list :publisher, 50
FactoryBot.create_list :author, 100

FactoryBot.create_list :book, 500, :has_cover

Category.update_all_counts

%i[forsida um_bokatidindi argangar open_data privacy_policy].each do |slug|
  FactoryBot.create(:page, slug: slug)
end
