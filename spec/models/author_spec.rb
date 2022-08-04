# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  context 'name' do
    it 'is automatically assembled from first name and last name' do
      author = create(:author)
      expect(author.name).not_to be_empty
      expect(author.name).to eq("#{author.firstname} #{author.lastname}")
    end
  end
end
