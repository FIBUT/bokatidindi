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

  context 'firstname and lastname' do
    it 'are automatically stipped of spaces' do
      author = create(
        :author, is_icelandic: false,
                 firstname: ' Xavier ',
                 lastname: ' Salomó  '
      )
      expect(author.name).to eq('Xavier Salomó')
      expect(author.order_by_name).to eq('Salomó, Xavier')
    end
  end
end
