# frozen_string_literal: true

class EditionCoverImageSrcsetsToJson < ActiveRecord::Migration[7.0]
  def change
    # rubocop:disable Rails/ReversibleMigration
    remove_column :editions, :cover_image_srcsets
    # rubocop:enable Rails/ReversibleMigration
    add_column :editions, :cover_image_srcsets, :json
  end
end
