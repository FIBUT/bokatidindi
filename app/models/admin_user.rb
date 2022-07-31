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
end
