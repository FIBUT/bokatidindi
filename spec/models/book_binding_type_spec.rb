# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookBindingType, type: :model do
  it 'Generates valid random ISBN numbers for testing' do
    book = Book.last
    2_500.times do
      expect(
        build(
          :book_binding_type, book:, barcode: BookBindingType.random_isbn
        )
      ).to be_valid
    end
  end
end
