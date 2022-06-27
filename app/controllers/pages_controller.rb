# frozen_string_literal: true

class PagesController < ApplicationController
  def um_bokatidindi
    @image_format = image_format
  end

  def privacy_policy; end

  private

  def image_format
    return 'jpg' if browser.ie?
    return 'jpg' if browser.safari? && browser.platform.mac?('<11.6')
    return 'jpg' if browser.platform.ios?('<14')
    return 'jpg' if browser.platform.kai_os?

    'webp'
  end
end
