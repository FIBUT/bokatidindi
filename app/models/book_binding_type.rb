# frozen_string_literal: true

class BookBindingType < ApplicationRecord
  belongs_to :book
  belongs_to :binding_type

  delegate :name, to: :binding_type
end
