class BookAuthor < ApplicationRecord
  default_scope { order(id: :DESC) }

  belongs_to :book
  belongs_to :author
  belongs_to :author_type

  def name
    [author.firstname, author.lastname].join(' ')
  end
end
