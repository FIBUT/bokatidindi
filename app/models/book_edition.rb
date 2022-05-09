class BookEdition < ApplicationRecord
  belongs_to :book
  belongs_to :edition
end
