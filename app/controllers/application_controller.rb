class ApplicationController < ActionController::Base
  before_action :redirect_root_domain

  private

  def redirect_root_domain
    return nil unless request.host == 'bokatidindi.is' || request.host == 'bokatidindi-staging.herokuapp.com'

    redirect_to(
      "#{request.protocol}www.bokatidindi.is#{request.fullpath}",
      status: 301,
      allow_other_host: true
    )
  end
end
