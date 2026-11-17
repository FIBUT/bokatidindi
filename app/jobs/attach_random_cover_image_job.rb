# frozen_string_literal: true

class AttachRandomCoverImageJob < ApplicationJob
  queue_as :default

  def perform(book)
    image_file_name = "book#{[1, 2, 3, 4, 5].sample}.jpg"
    book.cover_image.attach(
      io: File.open(Rails.root.join("spec/assets/#{image_file_name}")),
      filename: SecureRandom.uuid
    )
    book.attach_cover_image_variants
  end
end
