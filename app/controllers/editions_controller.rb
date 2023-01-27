# frozen_string_literal: true

class EditionsController < ApplicationController
  def show
    edition = if params[:id] == 'current'
                Edition.current.first
              else
                Edition.find(params[:id])
              end

    include_images = (params[:include_images] == 'true')

    respond_to do |format|
      format.xml do
        render(xml: edition_books(edition, include_images))
      end
      format.json do
        render(json: edition_books(edition, include_images))
      end
    end
  end

  def index
    @image_format    = image_format
    @editions        = Edition.order(year: :desc)
  end

  private

  def image_format
    return 'jpg' if browser.ie?
    return 'jpg' if browser.safari? && browser.platform.mac?('<11.6')
    return 'jpg' if browser.platform.ios?('<14')
    return 'jpg' if browser.platform.kai_os?

    'webp'
  end

  def edition_books(edition, include_images = false)
    books = []
    Book.includes(
      book_editions: { book_edition_categories: [:category] },
      book_authors: %i[author author_type],
      book_binding_types: [:binding_type],
      publisher: []
    ).order(
      id: :asc
    ).where(
      book_editions: { edition_id: edition.id }
    ).with_attached_cover_image.each do |b|
      book = edition_book(b, edition.id)
      if include_images && b.cover_image?
        book[:book_cover_image_url] = b.cover_image.url
        book[:book_print_cover_image] = b.print_image_variant_url
      end
      books << book
    end
    books
  end

  def edition_book(book, edition_id)
    {
      id: book.id,
      pre_title: book.pre_title,
      title: book.title_noshy,
      post_title: book.post_title,
      slug: book.slug,
      description: book.description,
      long_description: book.long_description,
      authors: book_authors(book),
      main_authors: book.main_authors_string,
      publisher: {
        id: book.publisher_id,
        slug: book.publisher.slug,
        name: book.publisher.name,
        url: publisher_url(book.publisher.slug)
      },
      binding_types: book_binding_types(book),
      categories: book_categories(book, edition_id),
      url: book_url(book.slug)
    }
  end

  def book_categories(book, edition_id)
    book_edition_categories = book.book_editions.find do |book_edition|
      book_edition[:edition_id] == edition_id
    end.book_edition_categories
    categories = []
    book_edition_categories.each do |bec|
      categories << {
        id: bec.category.id,
        slug: bec.category.slug,
        name: bec.category.name,
        group: I18n.t(
          "activerecord.attributes.category.groups.#{bec.category.group}"
        ),
        url: category_url(bec.category.slug)
      }
    end
    categories
  end

  def book_authors(book)
    book_authors = []
    book.book_authors.each do |ba|
      book_authors << {
        id: ba.author.id,
        type_name: ba.author_type.name,
        type_plural_name: ba.author_type.plural_name,
        type_abbreviation: ba.author_type.abbreviation,
        type_id: ba.author_type.id,
        slug: ba.author.slug,
        name: ba.author.name,
        order_by_name: ba.author.order_by_name,
        is_icelandic: ba.author.is_icelandic,
        gender: ba.author.gender,
        url: author_url(ba.author.slug)
      }
    end
    book_authors
  end

  def book_binding_types(book)
    book_binding_types = []
    book.book_binding_types.each do |bbt|
      book_binding_types << {
        barcode: bbt.barcode,
        binding_type_id: bbt.binding_type.id,
        binding_type_name: bbt.binding_type.name,
        binding_type_slug: bbt.binding_type.slug
      }
    end
    book_binding_types
  end
end
