# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'controller' do
    it 'renders the index template using valid HTML' do
      get '/'
      html_doc = Nokogiri::HTML5::Document.parse(response.body)
      expect(html_doc.errors).to be_empty
    end
  end
end
