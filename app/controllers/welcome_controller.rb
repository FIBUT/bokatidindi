# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    @image_format = image_format
    @meta_description = ' Bókatíðindi hafa síðan 1928 veitt yfirlit yfir '\
                        'útgáfu ársins fyrir bókaunnendur. Þar má alltaf '\
                        'nálgast upplýsingar um þær bækur sem gefnar eru '\
                        'út á hverju ári.'
  end

  def image_format
    return 'jpg' if browser.ie?
    return 'jpg' if browser.safari? && browser.platform.mac?('<11.6')
    return 'jpg' if browser.platform.ios?('<14')
    return 'jpg' if browser.platform.kai_os?

    'webp'
  end
end
