# frozen_string_literal: true

class SetEditionImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(edition)
    edition.update_cover_image_srcsets
    edition.save
  end
end
