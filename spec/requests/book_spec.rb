# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  describe 'controller' do
    it 'renders the index template' do
      100.times do
        book = create(:book)
        create(:book_edition, book:)

        image_file_name = "book#{[1, 2, 3, 4, 5].sample}.jpg"
        image_contents = File.read(
          Rails.root.join("spec/assets/#{image_file_name}")
        )
        book.attach_cover_image_from_string(image_contents)
      end

      get '/baekur'

      expect(response.status).to eq(200)
      expect(response).to render_template('index')
    end

    it 'renders the show template' do
      book = create(
        :book,
        book_authors: [build(:book_author)],
        book_categories: [build(:book_category)]
      )
      create(:book_author, book_id: book[:id])
      create(:book_binding_type, book_id: book[:id])
      create(:book_edition, book_id: book[:id])

      get "/bok/#{book.slug}"
      expect(response.status).to eq(200)
      expect(response).to render_template('show')
    end
  end
end
