# frozen_string_literal: true

class BooksController < ApplicationController
  def index
    @image_format = image_format

    if params[:search]
      @title_tag = "Bókatíðindi - Leitarniðurstöður - #{params[:search]}"
      book_results = Book.joins(:book_editions).search(params[:search])

      @books                   = []
      @books_from_old_editions = []

      book_results.each do |b|
        if b.current_edition?
          @books << b
        else
          @books_from_old_editions << b
        end
      end

      return redirect_to book_path(@books.first[:slug]) if @books.length == 1
    else
      if params[:category]
        @category = Category.find_by(slug: params[:category])

        @title_tag = "Bókatíðindi - Flokkur - #{@category[:name_with_group]}"
        @meta_description = 'Bækur í Bókatíðindum í vöruflokknum '\
                            "#{@category[:name_with_group]}"

        @books = Book.joins(
          book_editions: :book_edition_categories
        ).where(
          book_editions: { edition_id: Edition.active.first },
          book_edition_categories: {
            category_id: @category[:id], for_web: true
          }
        ).order(:title).group('books.id')
      end
      if params[:publisher]
        @publisher = Publisher.find_by(slug: params[:publisher])

        @title_tag = "Bókatíðindi - Útgefandi - #{@publisher[:name]}"
        @meta_description = "Bækur í Bókatíðindum frá #{@publisher[:name]}"

        @books = Book.joins(
          book_editions: :book_edition_categories
        ).where(
          publisher_id: @publisher[:id],
          book_editions: { edition_id: Edition.active.first },
          book_edition_categories: { for_web: true }
        ).order(:title).group('books.id')
      end
      if params[:author]
        @author = Author.find_by(slug: params[:author])

        @title_tag = "Bókatíðindi - Höfundur - #{@author[:name]}"
        @meta_description = "Bækur eftir höfundinn #{@author[:name]}"

        @books = Book.left_joins(
          :book_authors
        ).left_joins(
          book_editions: [:book_edition_categories]
        ).where(
          book_authors: { author_id: @author[:id] },
          book_editions: { edition_id: Edition.active.first },
          book_edition_categories: { for_web: true }
        ).order(:title).group('books.id')
      end

      unless @books.nil?
        return @books = @books.order(:title).page(params[:page])
      end

      @books = Book.left_joins(
        book_editions: [:book_edition_categories]
      ).where(
        book_editions: { edition_id: Edition.active.first },
        book_edition_categories: { for_web: true }
      ).order(:title).group('books.id').page(params[:page])
    end
  end

  def show
    @image_format = image_format

    @book = Book.joins(
      :publisher,
      book_editions: [:edition],
      book_binding_types: [:binding_type],
      book_authors: %i[author author_type],
      book_categories: [:category]
    ).find_by(slug: params[:slug])

    unless @book
      render file: 'public/404.html', status: :not_found,
             layout: false
    end

    true
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
