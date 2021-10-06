class BookBindingType < ApplicationRecord
  belongs_to :book
  belongs_to :binding_type

  def name
    binding_type.name
  end
end
