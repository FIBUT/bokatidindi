class Category < ApplicationRecord
  NAME_MAPPINGS = [
    { source_id: 3, name: 'Íslensk skáldverk', group: 'skaldverk', group_h: 'Skáldverk' },
    { source_id: 4, name: 'Þýdd skáldverk', group: 'skaldverk', group_h: 'Skáldverk' },
    { source_id: 5, name: 'Ljóð og leikrit', group: 'skaldverk', group_h: 'Skáldverk' },
    { source_id: 6, name: 'Listir og ljósmyndir', group: 'fraedibaekur', group_h: 'Fræðibækur' },
    { source_id: 7, name: 'Fræðibækur', group: 'fraedibaekur', group_h: 'Fræðibækur' },
    { source_id: 8, name: 'Saga, ættfræði og héraðslýsingar', group: 'fraedibaekur', group_h: 'Fræðibækur' },
    { source_id: 9, name: 'Ævisögur', group: 'aevisogur', group_h: 'Ævisögur' },
    { source_id: 11, name: 'Matur', group: 'fraedibaekur', group_h: 'Fræðibækur' },
    { source_id: 14, name: 'Hannyrðir, íþróttir og útivist', group: 'fraedibaekur', group_h: 'Fræðibækur' },
    { source_id: 20, name: 'Myndskreyttar 0-6 ára', group: 'barnabaekur', group_h: 'Barnabækur' },
    { source_id: 21, name: 'Skáldverk', group: 'barnabaekur', group_h: 'Barnabækur' },
    { source_id: 22, name: 'Fræðibækur og handbækur', group: 'barnabaekur', group_h: 'Barnabækur' },
    { source_id: 23, name: 'Ungmennabækur', group: 'barnabaekur', group_h: 'Barnabækur' }
  ].freeze

  has_many :books, through: :book_categories

  before_create :set_slug

  def name
    mapped_name = NAME_MAPPINGS.find { |c| c[:source_id] == source_id }
    return mapped_name[:name] unless mapped_name.nil?

    origin_name
  end

  def name_with_group
    mapped_name = NAME_MAPPINGS.find { |c| c[:source_id] == source_id }
    return origin_name if mapped_name.nil?

    return mapped_name[:name].to_s unless mapped_name[:group] == 'barnabaekur'

    return "#{mapped_name[:group_h]} - #{mapped_name[:name]}"
  end

  def books_url
    "/baekur/?category=#{slug}"
  end

  private

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
