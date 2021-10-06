class BooksController < ApplicationController
  def index
    @books = Book.order(:title).eager_load(
      :book_authors, :authors, :publisher, :category, :book_binding_types
    )
    @books = @books.where(publishers: { slug: params[:publisher] }) if params[:publisher]
    @books = @books.where(categories: { slug: params[:category] }) if params[:category]
    @books = @books.where(authors: { slug: params[:author] }) if params[:author]
    @books = @books.page params[:page]
  end

  def show
    @book = Book.find_by(slug: params[:slug])
  end

end
