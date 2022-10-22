# frozen_string_literal: true

class AddSrcsetsToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :cover_image_srcsets, :json, default: {
      'webp': [], 'jpg': []
    }
    add_column :books, :sample_pages_srcsets, :json, default: {
      'webp': [], 'jpg': []
    }
  end
end
