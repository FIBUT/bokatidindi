# frozen_string_literal: true

class AdminUserPublisher < ApplicationRecord
  belongs_to :admin_user
  belongs_to :publisher
end
