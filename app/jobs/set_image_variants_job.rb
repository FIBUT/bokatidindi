# frozen_string_literal: true

class SetImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.update_srcsets
    book.save
  end
end
