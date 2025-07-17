# frozen_string_literal: true

class Blockquote < ApplicationRecord
  QUOTE_MAX_LENGTH    = 512
  CITATION_MAX_LENGTH = 63

  belongs_to :book

  default_scope { order(id: :asc) }

  enum :quote_type, %i[citation direct]
  enum :location, %i[below_long_description below_book_description]
end
