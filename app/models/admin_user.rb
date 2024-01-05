# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable,
         :recoverable, :rememberable, :validatable, :lockable

  has_many :admin_user_publishers, dependent: :destroy
  has_many :publishers, through: :admin_user_publishers

  accepts_nested_attributes_for :admin_user_publishers

  enum :role, %i[guest publisher admin]

  validates :name, :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true

  validates :role, presence: true

  validates :admin_user_publishers, length: { minimum: 1 }, if: :publisher?
  validates :admin_user_publishers, length: { is: 0 }, if: :admin?
  validates :admin_user_publishers, length: { is: 0 }, if: :guest?

  def self.ransackable_attributes(_auth_object = nil)
    ['created_at', 'current_sign_in_at', 'current_sign_in_ip', 'email',
     'encrypted_password', 'failed_attempts', 'id', 'last_sign_in_at',
     'last_sign_in_ip', 'locked_at', 'name', 'remember_created_at',
     'reset_password_sent_at', 'reset_password_token', 'role', 'sign_in_count',
     'unlock_token', 'updated_at']
  end

  def self.ransackable_associations(_auth_object = nil)
    ['admin_user_publishers', 'publishers']
  end
end
