# frozen_string_literal: true

class SetDefaultValueForEditionCoverImageSrcsets < ActiveRecord::Migration[7.0]
  def change
    change_column_default(
      :editions, :cover_image_srcsets,
      from: '', to: { 'webp' => '', 'jpg' => '' }
    )
  end
end
