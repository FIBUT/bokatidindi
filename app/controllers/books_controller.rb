class BooksController < ApplicationController
  def index
    @image_format = image_format

    if params[:search]
      @books = Book.search(params[:search])
    else
      @books = Book.order(:title).eager_load(
        :book_authors, :authors, :publisher, :book_categories, :book_binding_types
      ).includes(cover_image_attachment: [:blob])

      if params[:category]
        unless Category.find_by(slug: params[:category])
          render file: 'public/404.html', status: 404, layout: false
        end

        @books = @books.joins(:categories).where(
          book_categories: { categories: { slug: params[:category] } }
        )
        @category = Category.find_by(slug: params[:category])
      end
      if params[:publisher]
        unless Publisher.find_by(slug: params[:publisher])
          render file: 'public/404.html', status: 404, layout: false
        end

        @books = @books.where(publishers: { slug: params[:publisher] })
        @publisher = Publisher.find_by(slug: params[:publisher])
      end
      if params[:author]
        unless Author.find_by(slug: params[:author])
          render file: 'public/404.html', status: 404, layout: false
        end

        @books = @books.where(authors: { slug: params[:author] })
        @author = Author.find_by(slug: params[:author])
      end
      @books = @books.page params[:page]
    end
  end

  def show
    @image_format = image_format

    @book = Book.find_by(slug: params[:slug])

    unless @book
      render file: 'public/404.html', status: 404, layout: false
    end
  end

  private

  def image_format
    return 'jpg' if browser.ie?
    return 'jpg' if browser.safari? && browser.platform.mac?('<11.6')
    return 'jpg' if browser.platform.ios?('<14')
    return 'jpg' if browser.platform.kai_os?

    'webp'
  end
end
