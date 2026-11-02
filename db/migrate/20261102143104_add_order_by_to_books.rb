# frozen_string_literal: true

class AddOrderByToBooks < ActiveRecord::Migration[8.1]
  def up
    add_column :books, :order_by, :integer, default: 0
    add_column :books, :order_by_title, :string, default: nil

    Book.all.find_each do |b|
      SetOrderByTitlesJob.perform_later b
    end
  end

  def down
    remove_column :books, :order_by
    remove_column :books, :order_by_title
  end
end
