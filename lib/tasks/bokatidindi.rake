namespace :bokatidindi do
  desc "TODO"
  task attach_cover_image: :environment do
    Book.all.each do |b|
      unless b.cover_image.attached?
        b.attach_cover_image
        puts "#{b.id}: #{b.original_cover_bucket_url}"
      end
    end
  end

end
