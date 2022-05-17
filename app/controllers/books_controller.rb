class BooksController < ApplicationController
  def index
    @image_format = image_format

    if params[:search]
      @title_tag = "Bókatíðindi - Leitarniðurstöður - #{params[:search]}"
      @books = Book.search(params[:search]).reverse

      return redirect_to book_path(@books.first.slug) if @books.length == 1
    else
      @title_tag = 'Bókatíðindi'
      @books = Book.order(:title).eager_load(
        :book_authors, :authors, :publisher, :book_categories,
        :book_binding_types, :book_editions
      ).includes(
        :publisher,
        book_categories: [:category],
        book_authors: [:author_type, :author],
        book_binding_types: [:binding_type],
        cover_image_attachment: [:blob]
      ).where(
        book_editions: { 'edition_id': Edition.find_by(active: true) }
      )

      if params[:category]
        @category = Category.find_by(slug: params[:category])
        unless @category
          return render file: 'public/404.html', status: 404, layout: false
        end

        @title_tag << " - Flokkur - #{@category.name_with_group}"
        @meta_description = "Bækur í vöruflokknum #{@category.name_with_group}"

        @books = @books.joins(:categories).where(
          book_categories: { categories: { slug: params[:category] } }
        )
      end
      if params[:publisher]
        @publisher = Publisher.find_by(slug: params[:publisher])
        unless @publisher
          return render file: 'public/404.html', status: 404, layout: false
        end

        @title_tag << " - Útgefandi - #{@publisher.name}"
        @meta_description = "Bækur frá útgefandanum #{@publisher.name}"

        @books = @books.where(publishers: { slug: params[:publisher] })
      end
      if params[:author]
        @author = Author.find_by(slug: params[:author])
        unless @author
          return render file: 'public/404.html', status: 404, layout: false
        end

        @title_tag << " - Höfundur - #{@author.name}"
        @meta_description = "Bækur eftir höfundinn #{@author.name}"

        @books = @books.where(authors: { slug: params[:author] })
      end

      unless @books
        return render file: 'public/404.html', status: 404, layout: false
      end

      @books = @books.page params[:page]
    end
  end

  def show
    @image_format = image_format

    @book = Book.joins(
      :publisher,
      book_editions: [:edition],
      book_binding_types: [:binding_type],
      book_authors: [:author, :author_type],
      book_categories: [:category],
    ).find_by(slug: params[:slug])

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
