# frozen_string_literal: true

class BookAuthor < ApplicationRecord
  belongs_to :book
  belongs_to :author
  belongs_to :author_type

  validates(
    :author, inclusion: {
      in: Author.all, unless: proc { |ba| ba.author_type.blank? }
    }
  )
  validates(
    :author_type, inclusion: {
      in: AuthorType.all, unless: proc { |ba| ba.author_type.blank? }
    }
  )

  def name
    [author.firstname, author.lastname].join(' ')
  end
end
