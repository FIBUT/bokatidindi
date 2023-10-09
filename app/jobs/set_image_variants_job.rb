# frozen_string_literal: true

class SetImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.attach_cover_image_variants
    book.attach_sample_page_variants
    book.update_srcsets
  end
end
