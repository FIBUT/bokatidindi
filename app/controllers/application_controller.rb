# frozen_string_literal: true

class ApplicationController < ActionController::Base
  REDIRECT_FROM = ['bokatidindi.is', 'bokatidindi.herokuapp.com'].freeze

  before_action :redirect_root_domain

  def not_found
    render(
      file: Rails.root.join('public/404.html'), layout: false,
      status: :not_found
    )
  end

  def access_denied(_exception)
    render(
      status: :unauthorized,
      file: Rails.root.join('public/403.html'), layout: false
    )
  end

  def bad_request(_exception)
    render(
      status: :bad_request, layout: false,
      plain: 'HTTP-villa 400: Villa í fyrirspurn'
    )
  end

  private

  def redirect_root_domain
    return nil unless REDIRECT_FROM.include?(request.host)
    return nil if ENV.include?('STAGING_MODE')

    redirect_to(
      "#{request.protocol}www.bokatidindi.is#{request.fullpath}",
      status: :moved_permanently,
      allow_other_host: true
    )
  end

  def image_format
    j = JpgOrWebp.new(request.user_agent)
    j.image_format
  end
end
