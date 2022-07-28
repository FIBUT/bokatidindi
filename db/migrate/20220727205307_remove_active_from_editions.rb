# frozen_string_literal: true

class RemoveActiveFromEditions < ActiveRecord::Migration[7.0]
  def change
    remove_column(:editions, :active, type: :boolean)
  end
end
