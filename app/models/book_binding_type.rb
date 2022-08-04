# frozen_string_literal: true

class BookBindingType < ApplicationRecord
  AVAILABLE_LANGUAGES = [
    ['Íslenska', 'is'], ['Enska', 'en'], ['Danska', 'da'], ['Norska', 'no'],
    ['Finnska', 'fi'], ['Þýska', 'de'], ['Franska', 'fr'],
    ['Spænska', 'sp'], ['Ítalska', 'it'], ['Japanska', 'ja'],
    ['Kínverska', 'zh']
  ].freeze

  belongs_to :book
  belongs_to :binding_type

  delegate :name, to: :binding_type

  def language_name
    language_a[0]
  end

  private

  def language_a
    AVAILABLE_LANGUAGES.find { |l| l[1] == language }
  end
end
