# frozen_string_literal: true

class AddCoverImageSrcsetsToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :cover_image_srcsets, :string
  end
end
