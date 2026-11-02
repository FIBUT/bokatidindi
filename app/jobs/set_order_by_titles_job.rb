# frozen_string_literal: true

class SetOrderByTitlesJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.set_order_by_title
    book.save
  end
end
