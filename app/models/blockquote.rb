# frozen_string_literal: true

class Blockquote < ApplicationRecord
  QUOTE_MAX_LENGTH    = 512
  CITATION_MAX_LENGTH = 63

  belongs_to :book

  default_scope { order(id: :asc) }

  enum size: { medium: 0, large: 1, extra_large: 2 }
  enum location: { below_long_description: 0, below_book_description: 1 }
end
