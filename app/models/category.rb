class Category < ApplicationRecord
  NAME_MAPPINGS = [
    { source_id: 3, name: 'Íslensk skáldverk' },
    { source_id: 4, name: 'Þýdd skáldverk' },
    { source_id: 4, name: 'Ljóð og leikrit' },
    { source_id: 6, name: 'Listir og ljósmyndir' },
    { source_id: 7, name: 'Fræðibækur' },
    { source_id: 8, name: 'Saga, ættfræði og héraðslýsingar' },
    { source_id: 9, name: 'Ævisögur' },
    { source_id: 11, name: 'Matur' },
    { source_id: 14, name: 'Hannyrðir, íþróttir og útivist' },
    { source_id: 20, name: 'Myndskreyttar 0-6 ára' },
    { source_id: 21, name: 'Skáldverk fyrir börn' },
    { source_id: 22, name: 'Fræðibækur og handbækur fyrir börn' },
    { source_id: 23, name: 'Ungmennabækur' }
  ].freeze

  has_many :books, through: :book_categories

  before_create :set_slug

  def name
    mapped_name = NAME_MAPPINGS.find { |c| c[:source_id] == source_id }
    return mapped_name[:name] unless mapped_name.nil?

    origin_name
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
