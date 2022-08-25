# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'XmlFeeds', type: :request do
  describe 'GET /xml_feeds/editions_for_print/:id' do
    it 'successfully renders' do
      get "/xml_feeds/editions_for_print/#{Edition.first.id}"
      expect(response.status).to eq(200)

      xml_doc = Nokogiri::XML(response.body)
      expect(xml_doc.errors).to be_empty
    end
  end
end
