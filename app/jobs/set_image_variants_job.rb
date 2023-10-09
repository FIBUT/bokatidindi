# frozen_string_literal: true

class SetImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.update_srcsets
    book.attach_sample_page_variants
    book.attach_cover_image_variants
    book.save
  end
end
