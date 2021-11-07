class ApplicationController < ActionController::Base
  before_action :redirect_root_domain

  private

  def redirect_root_domain
    return nil unless request.host == 'bokatidindi.is'

    redirect_to(
      "#{request.protocol}www.bokatidindi.is#{request.fullpath}",
      status: 301
    )
  end
end
