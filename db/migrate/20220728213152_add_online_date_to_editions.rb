# frozen_string_literal: true

class AddOnlineDateToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :online_date, :datetime
  end
end
