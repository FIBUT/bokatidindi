# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Indexes', type: :request do
  describe 'controller' do
    it 'renders the authors index template using valid HTML' do
      get '/hofundar'
      html_doc = Nokogiri::HTML5::Document.parse(response.body)
      expect(html_doc.errors).to be_empty
    end
    it 'renders the publishers index template using valid HTML' do
      get '/utgefendur'
      html_doc = Nokogiri::HTML5::Document.parse(response.body)
      expect(html_doc.errors).to be_empty
    end
  end
end
