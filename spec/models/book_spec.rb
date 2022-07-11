# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, type: :model do
  context 'cover images' do
    it 'are successfully uploaded, processed and presented' do
      book = create(:book)
      image_file_name = "book#{[1, 2, 3, 4, 5].sample}.jpg"
      image_contents = File.read(
        Rails.root.join("spec/assets/#{image_file_name}")
      )

      expect(book.cover_image_url).to eq(book.original_cover_bucket_url)
      expect(book.cover_image.attached?).not_to be_truthy

      book.attach_cover_image_from_string(image_contents)

      expect(book.cover_image.attached?).to be_truthy
      expect(book.cover_image_url).not_to eq(book.original_cover_bucket_url)

      # srcsets are valid
      srcset_array = book.cover_img_srcset.split(', ')
      variants = Book::COVER_IMAGE_VARIANTS

      expect(srcset_array.length).to eq(variants.length)

      srcset_array.each_with_index do |src, i|
        src_components = src.split(' ')

        # Variant URLs should be valid
        image_uri = URI.parse(src_components[0])
        expect(image_uri).to be_a(URI::HTTP)

        # Variant sizes are numeric, based on the Book::COVER_IMAGE_VARIANTS
        # constant and end with "w".
        expect(src_components[1]).to eq("#{variants[i]}w")
      end
    end
  end

  context 'title_noshy' do
    it 'displays a version of the title without a shy symbol' do
      book = create(:book, title: 'Holta&shy;vörðu&shy;heiði')

      expect(book.title_noshy).to eq('Holtavörðuheiði')
    end

    it 'updates with the title' do
      book = create(:book, title: 'Holta&shy;vörðu&shy;heiði')
      book.title = 'Vegavinnu&shy;verka&shy;manna&shy;skúrs&shy;lykla&shy;kippa'
      book.save

      expect(book.title_noshy).to eq('Vegavinnuverkamannaskúrslyklakippa')
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
