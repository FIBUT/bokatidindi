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

    it 'requires a publisher assigned to publisher users' do
      user = build(:publisher_user, publisher_id: nil)
      user.save
      expect(user.errors.first.attribute.to_s).to eq('publisher')
      expect(user.errors.first.type.to_s).to eq('blank')
    end

    it 'rejects admin users with an assigned publisher' do
      user = build(:admin_user, publisher: Publisher.last)
      user.save
      expect(user.errors.first.attribute.to_s).to eq('publisher')
      expect(user.errors.first.type.to_s).to eq('present')
    end
  end
end
