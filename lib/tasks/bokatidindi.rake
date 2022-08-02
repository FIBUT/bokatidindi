# frozen_string_literal: true

namespace :bt do
  desc 'Attach images of each cover to the books'
  task attach_covers: :environment do
    active_edition_id = Edition.current.first

    books = Book.joins(:editions).where(
      'editions.id': active_edition_id
    ).where.not(source_id: nil)

    books.each do |b|
      next if b.cover_image.attached?

      url = b.original_cover_bucket_url
      if b.attach_cover_image
        puts "✅ #{b.slug}: Image found and attached from #{url}"
      else
        puts "❌ #{b.slug}: Image not found at #{url}"
      end
      GC.start
    end
  end
  desc 'Update the hypenation processing of book titles'
  task update_hypenation: :environment do
    Book.all.each do |b|
      b.set_title_hypenation
      b.save
      puts "#{b.slug} - #{b.title_hypenated} (#{b.title})"
    end
  end
  desc 'Delete closed binding types with no books associated'
  task delete_empty_binding_types: :environment do
    BindingType.where(open: false).each do |b|
      b.destroy if b.book_count.zero?
    end
  end
  desc 'Rename categories to their display name'
  task rename_categories: :environment do
    category_mappings = [
      { id: 3, name: 'Íslensk skáldverk', g: 1 },
      { id: 4, name: 'Þýdd skáldverk', g: 1 },
      { id: 5, name: 'Ljóð og leikrit', g: 1 },
      { id: 6, name: 'Listir og ljósmyndir', g: 2 },
      { id: 7, name: 'Fræðibækur', g: 2 },
      { id: 8, name: 'Saga, ættfræði og héraðslýsingar', g: 2 },
      { id: 9, name: 'Ævisögur', g: 2 },
      { id: 11, name: 'Matur', g: 2 },
      { id: 14, name: 'Hannyrðir, íþróttir og útivist', g: 2 },
      { id: 20, name: 'Myndskreyttar 0-6 ára', g: 0 },
      { id: 21, name: 'Skáldverk', g: 0 },
      { id: 22, name: 'Fræðibækur og handbækur', g: 0 },
      { id: 23, name: 'Ungmennabækur', g: 0 }
    ].freeze

    category_mappings.each do |m|
      category = Category.find_by(source_id: m[:id])
      category[:name]  = m[:name]
      category[:group] = m[:g]
      category.save
    end
  end
end
