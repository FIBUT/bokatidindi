# frozen_string_literal: true

class AuthorType < ApplicationRecord
  enum :schema_role,
       { author: 0, translator: 1, editor: 2, ":illustrator": 3,
         contributor: 4, producer: 5 }
end
