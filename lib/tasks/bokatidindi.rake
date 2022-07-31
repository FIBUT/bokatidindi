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
end
