# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookBindingType, type: :model do
  it 'Generates valid random ISBN numbers for testing' do
    book = Book.last
    200.times do
      expect(
        build(
          :book_binding_type, book:, barcode: BookBindingType.random_isbn
        )
      ).to be_valid
    end
  end

  it 'Validates ISBNs' do
    binding_type = create(:binding_type, name: 'Bókabók', barcode_type: 'ISBN')

    expect do
      create(:book, book_binding_types: [
               create(:book_binding_type, barcode: '0258-3771',
                                          binding_type:),
               create(:book_binding_type, barcode: '9771234567898',
                                          binding_type:)
             ])
    end.to raise_error(ActiveRecord::RecordInvalid)

    expect do
      isbns = [BookBindingType.random_isbn, BookBindingType.random_isbn]
      2.times do
        create(:book, book_binding_types: [
                 create(:book_binding_type, barcode: isbns[0],
                                            binding_type:),
                 create(:book_binding_type, barcode: isbns[1],
                                            binding_type:)
               ])
      end
    end.to raise_error(ActiveRecord::RecordInvalid)

    expect do
      create(:book, book_binding_types: [
               create(:book_binding_type, barcode: BookBindingType.random_isbn,
                                          binding_type:),
               create(:book_binding_type, barcode: BookBindingType.random_isbn,
                                          binding_type:)
             ])
    end.not_to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'Validates ISSNs' do
    binding_type = create(:binding_type, name: 'Tímarit', barcode_type: 'ISSN')

    expect do
      3.times do
        create(:book, book_binding_types: [
                 create(:book_binding_type, barcode: '0258-3771',
                                            binding_type:),
                 create(:book_binding_type, barcode: '9771234567898',
                                            binding_type:)
               ])
      end
    end.not_to raise_error(ActiveRecord::RecordInvalid)

    expect do
      create(:book, book_binding_types: [
               create(:book_binding_type, barcode: BookBindingType.random_isbn,
                                          binding_type:),
               create(:book_binding_type, barcode: BookBindingType.random_isbn,
                                          binding_type:)
             ])
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end
