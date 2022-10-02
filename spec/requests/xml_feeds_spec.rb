# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'XmlFeeds', type: :request do
  describe 'GET /xml_feeds/editions_for_print/:id' do
    it 'successfully renders' do
      get "/xml_feeds/editions_for_print/#{Edition.first.id}"
      expect(response.status).to eq(200)

      xml_document = Nokogiri::XML.parse(
        response.body, nil, nil, Nokogiri::XML::ParseOptions::DTDLOAD
      )
      expect(xml_document.errors).to be_empty
      expect(xml_document.external_subset.validate(xml_document)).to be_empty
    end
  end
end
