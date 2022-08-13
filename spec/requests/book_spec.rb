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
        book_authors: [create(:book_author)],
        book_binding_types: [create(:book_binding_type)],
        book_categories: [create(:book_category)],
        editions: [Edition.first]
      )
      get "/bok/#{book.slug}"
      expect(response.status).to eq(200)
      expect(response).to render_template('show')
    end
  end
end
