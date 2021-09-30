class BookBindingType < ApplicationRecord
  belongs_to :book
  belongs_to :binding_type
end
