# frozen_string_literal: true

module ApplicationHelper
  def category_groups
    groups = {
      skaldverk: [], fraedibaekur: [], aevisögur: [], barnabaekur: [],
      aevisogur: []
    }

    Category::NAME_MAPPINGS.each do |c|
      groups[c[:group].to_sym] << c[:source_id]
    end
    groups
  end
end
