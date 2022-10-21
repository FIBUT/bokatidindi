# frozen_string_literal: true

class BooksController < ApplicationController
  def index
    @image_format = image_format

    if params[:search]
      render_search
      return redirect_to book_path(@books.first[:slug]) if @books.length == 1
    else
      render_category if params[:category]
      render_publisher if params[:publisher]
      render_author if params[:author]

      @books = Book.current if @books.nil?
      @books = @books.order(:title).page(params[:page])
    end
  end

  def show
    @image_format = image_format

    @book = Book.find_by(slug: params[:slug])

    unless @book
      render file: 'public/404.html', status: :not_found,
             layout: false
    end

    true
  end

  private

  def render_search
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
  end

  def render_author
    @author = Author.find_by(slug: params[:author])
    return not_found if @author.nil?

    @title_tag = "Bókatíðindi - Höfundur - #{@author[:name]}"
    @meta_description = "Bækur eftir höfundinn #{@author[:name]}"

    @books = Book.current_by_author(@author.id).with_attached_cover_image
  end

  def render_publisher
    @publisher = Publisher.find_by(slug: params[:publisher])
    return not_found if @publisher.nil?

    @title_tag = "Bókatíðindi - Útgefandi - #{@publisher[:name]}"
    @meta_description = "Bækur í Bókatíðindum frá #{@publisher[:name]}"

    @books = Book.current_by_publisher(@publisher.id).with_attached_cover_image
  end

  def render_category
    @category = Category.find_by(slug: params[:category])
    return not_found if @category.nil?

    @title_tag = "Bókatíðindi - Flokkur - #{@category[:name_with_group]}"
    @meta_description = 'Bækur í Bókatíðindum í vöruflokknum '\
                        "#{@category[:name_with_group]}"

    @books = Book.current_by_category(@category.id).with_attached_cover_image
  end

  def image_format
    return 'jpg' if browser.ie?
    return 'jpg' if browser.safari? && browser.platform.mac?('<11.6')
    return 'jpg' if browser.platform.ios?('<14')
    return 'jpg' if browser.platform.kai_os?

    'webp'
  end
end
