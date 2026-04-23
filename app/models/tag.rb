# frozen_string_literal: true

class Tag < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    ['title', 'title_plural', 'slug', 'description', 'active', 'rod']
  end
end
