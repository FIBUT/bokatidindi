# frozen_string_literal: true

class AddTitleHypenatedToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :title_hypenated, :string
  end
end
