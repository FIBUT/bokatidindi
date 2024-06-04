# frozen_string_literal: true

class Page < ApplicationRecord
  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end

  def self.ransackable_attributes(_auth_object = nil)
    column_names
  end
end
