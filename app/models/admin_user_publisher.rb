# frozen_string_literal: true

class AdminUserPublisher < ApplicationRecord
  belongs_to :admin_user
  belongs_to :publisher

  def self.ransackable_attributes(_auth_object = nil)
    ['admin_user_id', 'created_at', 'id', 'publisher_id', 'updated_at']
  end
end
