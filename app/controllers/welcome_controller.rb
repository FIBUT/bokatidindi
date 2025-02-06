# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    expires_in 1.hour, public: true

    @page_content = Page.find_by(slug: 'forsida')
    @image_format = image_format
    @meta_description = ' Bókatíðindi hafa síðan 1928 veitt yfirlit yfir '\
                        'útgáfu ársins fyrir bókaunnendur. Þar má alltaf '\
                        'nálgast upplýsingar um þær bækur sem gefnar eru '\
                        'út á hverju ári.'
  end
end
