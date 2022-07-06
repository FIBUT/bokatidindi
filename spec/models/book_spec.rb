# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  context 'title_noshy' do
    it 'displays a version of the title without a shy symbol' do
      book = create(:book, title: 'Holta&shy;vörðu&shy;heiði')

      expect(book.title_noshy).to eq('Holtavörðuheiði')
    end

    it 'updates with the title' do
      book = create(:book, title: 'Holta&shy;vörðu&shy;heiði')
      book.title = 'Vegavinnu&shy;verka&shy;manna&shy;ksúrs&shy;lykla&shy;kippa'
      book.save

      expect(book.title_noshy).to eq('Vegavinnuverkamannaksúrslyklakippa')
    end
  end

  context 'slug' do
    it 'is generated on creation' do
      book = create(:book)

      expect(book.slug).to start_with(
        book.title_noshy.parameterize(locale: :is).first(64)
      )
      expect(book.slug).to end_with(book.source_id.to_s)
    end

    it 'will not change its value when the title is edited' do
      book = create(:book)
      original_slug = book.slug.freeze
      book.title = FFaker::Lorem.phrase.chop
      book.save

      expect(book.slug).to eq(original_slug)
    end
  end
end
