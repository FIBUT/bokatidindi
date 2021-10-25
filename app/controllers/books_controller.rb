class BooksController < ApplicationController
  def index
    @image_format = if browser.ie?
                      'jpg'
                    else
                      'webp'
                    end

    @books = Book.order(:title).eager_load(
      :book_authors, :authors, :publisher, :book_categories, :book_binding_types
    ).includes(cover_image_attachment: [:blob])

    if params[:category]
      @books = @books.joins(:categories).where(
        book_categories: { categories: { slug: params[:category] } }
      )
    end

    @books = @books.where(publishers: { slug: params[:publisher] }) if params[:publisher]
    @books = @books.where(authors: { slug: params[:author] }) if params[:author]
    @books = @books.page params[:page]
  end

  def show
    @image_format = if browser.ie?
                      'jpg'
                    else
                      'webp'
                    end

    @book = Book.find_by(slug: params[:slug])
  end

end
