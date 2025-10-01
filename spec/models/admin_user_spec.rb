# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  context 'validations' do
    it 'requires password confirmation matching on creation' do
      user = build(
        :admin_user,
        password: 'password', password_confirmation: 'drowssap'
      )
      user.save
      expect(user.errors.size).to be_truthy
    end
  end

  context 'relations' do
    it 'allow users to be deleted even if they\'ve added an author' do
      publisher = build(:publisher)
      publisher.save

      user = build(:publisher_user, publishers: [publisher])
      user.save

      author = build(:author)
      author[:added_by_id] = user[:id]
      author.save

      user.destroy

      expect(AdminUser.where(id: user.id).present?).to eq(false)
    end
  end
end
