class BindingType < ApplicationRecord
  AUDIO_BOOK_SOURCES = [3, 14, 15].freeze

  default_scope { order('rod ASC, name ASC') }

  before_create :set_slug

  def corrected_name
    return 'Hljóðbók' if AUDIO_BOOK_SOURCES.include?(source_id)

    name
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
