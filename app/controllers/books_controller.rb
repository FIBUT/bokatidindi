# frozen_string_literal: true

class BooksController < ApplicationController
  def index
    expires_in 1.hour, public: true

    @image_format = image_format

    @image_sizes = '(min-width: 2000px) 260px, '\
                   '(min-width: 1400px) 150px, '\
                   '(min-width: 1230px) 260px, '\
                   '(min-width: 992px) 150px, '\
                   '(min-width: 720px) 550px, '\
                   '(min-width: 670px) 260px, '\
                   '(min-width: 420px) 550px, '\
                   '(max-width: 420px) 260px'

    if params[:search]
      render_search
      book_results = @books + @books_from_old_editions
      if book_results.length == 1
        redirect_to book_path(book_results.first[:slug])
      end
    else
      return render_category if params[:category]
      return render_publisher if params[:publisher]
      return render_author if params[:author]

      # List out all the books if we have chosen not to isolate them by
      # category, author or publisher
      @books = Book.current.for_web if @books.nil?
      @meta_description = 'Allar bækur'

      @books = @books.order(:title).page(params[:page])
      @title_tag ||= 'Bókatíðindi - Allar bækur'

      unless (%i[category publisher author] & params.keys).any?
        prepare_navigation_metadata(
          'https://www.bokatidindi.is/baekur/',
          'Allar bækur'
        )
      end
    end
  end

  def show
    expires_in 1.hour, public: true

    @image_format = image_format

    @book = Book.find_by(slug: params[:slug])

    @image_sizes = '( min-width: 1050px ) 550px, '\
                   '( min-width: 900px ) 260px, '\
                   '( min-width: 670px ) 150px, '\
                   '( max-width: 670px ) 550px'\

    unless @book
      render file: 'public/404.html', status: :not_found,
             layout: false
    end

    true
  end

  private

  def render_search
    @title_tag = "Bókatíðindi - Leitarniðurstöður - #{params[:search]}"
    @meta_description = "Leitarniðurstöður: #{params[:search]}"

    book_results = Book.search(params[:search]).joins(
      book_editions: :book_edition_categories
    ).where(
      book_editions: {
        book_edition_categories: { for_web: true }
      }
    ).includes(
      book_editions: [:book_edition_categories]
    ).with_attached_cover_image.limit(100).uniq

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

    author_books = Book.by_author(@author)

    @books = author_books.with_attached_cover_image.order(:title)
                         .page(params[:page])

    @books_from_old_editions = author_books - @books

    prepare_navigation_metadata(
      "https://www.bokatidindi.is/baekur/hofundur/#{@author.slug}",
      @author[:name]
    )

    return unless @books.page(params[:page]).out_of_range?

    render file: 'public/404.html', status: :not_found, layout: false
  end

  def render_publisher
    @publisher = Publisher.find_by(slug: params[:publisher])
    return not_found if @publisher.nil?

    @title_tag = "Bókatíðindi - Útgefandi - #{@publisher[:name]}"
    @meta_description = "Bækur í Bókatíðindum frá #{@publisher[:name]}"

    @books = Book.current.for_web.by_publisher(@publisher.id)
                 .with_attached_cover_image.order(:title).page(params[:page])

    prepare_navigation_metadata(
      "https://www.bokatidindi.is/baekur/utgefandi/#{@publisher.slug}",
      @publisher[:name]
    )

    return unless @books.page(params[:page]).out_of_range?

    render file: 'public/404.html', status: :not_found, layout: false
  end

  def render_category
    @category = Category.find_by(slug: params[:category])
    return not_found if @category.nil?

    @title_tag = "Bókatíðindi - Flokkur - #{@category.name_with_group}"
    @meta_description = 'Bækur í Bókatíðindum í vöruflokknum '\
                        "#{@category.name_with_group}"

    @books = Book.current.for_web.by_category(@category.id)
                 .with_attached_cover_image.order(:title).page(params[:page])

    prepare_navigation_metadata(
      "https://www.bokatidindi.is/baekur/flokkur/#{@category.slug}",
      @category.name_with_group
    )

    return unless @books.page(params[:page]).out_of_range?

    render file: 'public/404.html', status: :not_found, layout: false
  end

  def prepare_navigation_metadata(base_url, name)
    current_page = @books.page(params[:page]).current_page
    last_page    = @books.page(params[:page]).last_page?
    first_page   = @books.page(params[:page]).first_page?

    @base_url = base_url
    @canonical_path = unless current_page == 1
                        "/sida/#{@books.page(params[:page]).total_pages}"
                      end
    @canonical_url = "#{@base_url}#{@canonical_path}"

    unless first_page
      @prev_path = if current_page == 2
                     ''
                   else
                     "/sida/#{@books.page(params[:page]).prev_page}"
                   end
    end

    unless last_page
      @next_path = "/sida/#{@books.page(params[:page]).next_page}"
    end

    @itemlist_ld_json = ld_json_category(@books, @base_url, name)
  end

  def ld_json_category(books, url, name)
    {
      '@context': 'https://schema.org',
      '@type': 'ItemList',
      '@id': url,
      url: url,
      name: name,
      numberOfItems: books.page(params[:page]).total_count,
      itemListElement: books.page(params[:page]).map.with_index do |b, i|
        ld_json_item(b, i, params[:page])
      end
    }
  end

  def ld_json_item(book, index, page)
    position = if page
                 index + 1 + Book::PAGINATION * (page.to_i - 1)
               else
                 index + 1
               end

    {
      '@type': 'ListItem',
      position: position,
      url: "https://www.bokatidindi.is/bok/#{book.slug}"
    }
  end
end
