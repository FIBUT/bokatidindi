# frozen_string_literal: true

class PrintLocation < ApplicationRecord
  default_scope { order(:name, :address) }

  scope :visible, lambda {
    where(visible: true)
  }

  enum :region, { capital: 1, sudurnes: 2, vesturland: 3,
                  vestfirdir: 4, nordurland_vestra: 5, nordurland_eystra: 6,
                  austurland: 7, sudurland: 8 }

  def self.ransackable_attributes(_auth_object = nil)
    ['address', 'created_at', 'id', 'latitude', 'longitude', 'name', 'region',
     'updated_at']
  end
end
