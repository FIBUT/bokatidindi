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

  def specification_rules
    {
      "prerender": [
        {
          "where": {
            "and": [
              { "href_matches": '/baekur/flokkur/*' },
              { "selector_matches": 'header nav a' }
            ]
          },
          "eagerness": 'moderate'
        },
        {
          "where": {
            "and": [
              { "href_matches": '/baekur/flokkur/*' },
              { "selector_matches": 'main .welcome-category-list a' }
            ]
          },
          "eagerness": 'moderate'
        },
        {
          "where": { "href_matches": '/baekur/hofundur/*' },
          "eagerness": 'moderate'
        },
        {
          "where": { "href_matches": '/baekur/utgefandi/*' },
          "eagerness": 'moderate'
        },
        {
          "where": { "href_matches": '/bok/*' },
          "eagerness": 'moderate'
        },
        {
          "where": { "href_matches": '/bok/*' },
          "eagerness": 'moderate'
        },
        {
          "where": { "selector_matches": '.book-cover a' },
          "eagerness": 'moderate'
        }
      ]
    }
  end
end
