# frozen_string_literal: true

namespace :bt do
  desc 'Attach images of each cover to the books'
  task attach_covers: :environment do
    active_edition_id = Edition.find_by(active: true).id

    books = Book.joins(:editions).where(
      'editions.id': active_edition_id
    )

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
end
