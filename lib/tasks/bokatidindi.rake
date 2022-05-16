namespace :bt do
  desc 'Attach images of each cover to the books'
  task attach_covers: :environment do
    Book.joins(:editions).where('editions.id' => Edition.last.id).each do |b|
      unless b.cover_image.attached?
        if b.attach_cover_image
          puts "✅ #{b.slug}: Image found and attached from #{b.original_cover_bucket_url}"
        else
          puts "❌ #{b.slug}: Image not found at #{b.original_cover_bucket_url}"
        end
        GC.start
      end
    end
  end

end
