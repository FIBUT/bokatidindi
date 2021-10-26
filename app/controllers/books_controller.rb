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
      @category = Category.find_by(slug: params[:category])
    end
    if params[:publisher]
      @books = @books.where(publishers: { slug: params[:publisher] })
      @publisher = Publisher.find_by(slug: params[:publisher])
    end
    if params[:author]
      @books = @books.where(authors: { slug: params[:author] })
      @author = Author.find_by(slug: params[:author])
    end
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
