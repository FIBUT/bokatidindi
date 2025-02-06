# frozen_string_literal: true

class PagesController < ApplicationController
  def um_bokatidindi
    expires_in 1.hour, public: true

    @page_content    = Page.find_by(slug: 'um_bokatidindi')
    @image_format    = image_format
    @current_edition = Edition.current_edition
  end

  def privacy_policy
    expires_in 1.hour, public: true

    @page_content = Page.find_by(slug: 'privacy_policy')
  end

  def open_data
    expires_in 1.hour, public: true

    @page_content = Page.find_by(slug: 'open_data')
  end
end
