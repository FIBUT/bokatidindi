# frozen_string_literal: true

require 'active_storage/service/gcs_service'
require 'uri'

class ActiveStorage::Service::GCSService
  private

  def public_url(key, **)
    return key unless ENV['CDN_URL']

    File.join(ENV['CDN_URL'], key)
  end
end
