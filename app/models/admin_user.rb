# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable,
         :recoverable, :rememberable, :validatable, :lockable

  belongs_to :publisher, optional: true

  enum :role, %i[guest publisher admin]

  validates :name, :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true

  validates :role, presence: true

  validates :publisher, presence: true, if: :publisher?
  validates :publisher, absence: true, if: :admin?
  validates :publisher, absence: true, if: :guest?
end
