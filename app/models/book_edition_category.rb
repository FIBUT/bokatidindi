# frozen_string_literal: true

class BookEditionCategory < ApplicationRecord
  belongs_to :book_edition
  belongs_to :category
end
