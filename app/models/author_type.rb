# frozen_string_literal: true

class AuthorType < ApplicationRecord
  enum :schema_role, %i[author translator editor :illustrator contributor producer]
end
