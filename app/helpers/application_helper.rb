# frozen_string_literal: true

module ApplicationHelper
  def markdown(text)
    options = %i[hard_wrap autolink no_intra_emphasis fenced_code_blocks
                 highlight no_images filter_html safe_links_only
                 prettify no_styles]
    Markdown.new(text, *options).to_html.html_safe
  end

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
