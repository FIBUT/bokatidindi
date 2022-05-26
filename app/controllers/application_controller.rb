class ApplicationController < ActionController::Base
  REDIRECT_FROM = ['bokatidindi.is', 'bokatidindi-staging.herokuapp.com'].freeze

  before_action :redirect_root_domain

  private

  def redirect_root_domain
    return nil unless REDIRECT_FROM.include?(request.host)

    redirect_to(
      "#{request.protocol}www.bokatidindi.is#{request.fullpath}",
      status: 301,
      allow_other_host: true
    )
  end
end
