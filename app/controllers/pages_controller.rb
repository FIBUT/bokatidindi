# frozen_string_literal: true

class PagesController < ApplicationController
  def um_bokatidindi
    @page_content    = Page.find_by(slug: 'um_bokatidindi')
    @image_format    = image_format
    @current_edition = Edition.current_edition
  end

  def privacy_policy
    @page_content    = Page.find_by(slug: 'privacy_policy')
  end

  def open_data
    @page_content    = Page.find_by(slug: 'open_data')
  end
end
