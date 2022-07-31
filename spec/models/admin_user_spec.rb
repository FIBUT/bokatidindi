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
end
