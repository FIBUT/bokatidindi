# frozen_string_literal: true

class SetImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.update_srcsets
    book.update_sample_pages_srcsets
    book.update_cover_image_srcsets
    book.save
  end
end
