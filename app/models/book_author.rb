# frozen_string_literal: true

class BookAuthor < ApplicationRecord
  belongs_to :book
  belongs_to :author
  belongs_to :author_type

  validates :author, inclusion: {
    in: Author.all
  }
  validates :author_type, inclusion: {
    in: AuthorType.all
  }

  def name
    [author.firstname, author.lastname].join(' ')
  end
end
