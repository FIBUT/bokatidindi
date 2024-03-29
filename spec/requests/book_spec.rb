# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  describe 'controller' do
    it 'renders the index template' do
      get '/baekur'

      expect(response.status).to eq(200)
      expect(response).to render_template('index')

      html_doc = Nokogiri::HTML5::Document.parse(response.body)
      expect(html_doc.errors).to be_empty
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

      html_doc = Nokogiri::HTML5::Document.parse(response.body)
      expect(html_doc.errors).to be_empty
    end

    it 'renders 404 errors when book resources are not found' do
      get '/bok/for-whom-the-bell-tolls-1234567'
      expect(response.status).to eq(404)
    end
    it 'renders 404 errors when author resources are not found' do
      get '/baekur/hofundur/ernest-hemmingway-9999'
      expect(response.status).to eq(404)
    end
    it 'renders 404 errors when publisher resources are not found' do
      get '/baekur/utgefandi/penugin-classics-454545'
      expect(response.status).to eq(404)
    end
    it 'renders 404 errors when category resources are not found' do
      get '/baekur/flokkur/brandarabaekur'
      expect(response.status).to eq(404)
    end
  end
end
