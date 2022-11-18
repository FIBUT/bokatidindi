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
      format.csv do
        send_data(edition_book_bindings_csv(edition, include_images),
                  filename: "bokatidindi_#{DateTime.now.to_i}.csv")
      end
    end
  end

  private

  def edition_books(edition, include_images = false)
    books = []
    Book.includes(
      book_editions: [],
      book_authors: %i[author author_type],
      book_binding_types: [:binding_type]
    ).order(
      id: :asc
    ).where(
      book_editions: { edition_id: edition.id }
    ).with_attached_cover_image.each do |b|
      book = edition_book(b, edition.id)
      if include_images && b.cover_image?
        book[:book_cover_image_url] = b.cover_image_url
        book[:book_print_cover_image] = b.print_image_variant_url
      end
      books << book
    end
    books
  end

  def edition_book(book)
    {
      id: book.id,
      title: book.full_title_noshy,
      slug: book.slug,
      description: book.description,
      long_description: book.long_description,
      authors: book_authors(book),
      binding_types: book_binding_types(book),
      categories: book_categories(book)
    }
  end

  def edition_book_bindings_csv(edition)
    book_bindings = edition_book_bindings_array(edition)
    CSV.generate do |csv|
      csv << book_bindings.first.keys
      book_bindings.each do |bbt|
        csv << bbt.values
      end
    end
  end

  def edition_book_bindings_array(edition)
    book_binding_types = []
    BookBindingType.includes(
      :binding_type, book: {
        book_editions: [], book_authors: %i[author author_type]
      }
    ).where(
      book: { book_editions: { edition_id: edition.id } }
    ).order(
      'book.id': :asc
    ).each do |bbt|
      book_binding_types << book_binding_type_for_csv(bbt)
    end
    book_binding_types
  end

  def book_binding_type_for_csv(bbt)
    bbt_item = {
      book_id: bbt.book.id,
      barcode: bbt.barcode,
      binding_type: bbt.binding_type.name,
      binding_type_slug: bbt.binding_type.slug,
      binding_type_id: bbt.binding_type.id,
      book_title: bbt.book.full_title_noshy,
      book_slug: bbt.book.slug,
      book_description: bbt.book.description.squish,
      book_long_description: bbt.book.long_description.squish,
      book_authors: book_authors_string(bbt.book)
    }
    if bbt.book.cover_image?
      bbt_item[:book_cover_image_url] = bbt.book.cover_image_url
      bbt_item[:book_print_cover_image] = bbt.book.print_image_variant_url
    end
    bbt_item
  end

  def book_authors_string(book)
    book_authors = []
    book.book_authors.sort_by(&:id).each do |ba|
      book_authors << "#{ba.author_type.name}: #{ba.author.name}"
    end
    book_authors.join('; ')
  end

  def book_categories(book)
    categories = []
    book.categories.each do |c|
      categories << {
        id: c.id,
        slug: c.slug,
        name: c.name,
        group: c.group
      }
    end
    categories
  end

  def book_authors(book)
    book_authors = []
    book.book_authors.each do |ba|
      book_authors << {
        type_name: ba.author_type.name,
        type_id: ba.author_type.id,
        slug: ba.author.slug,
        name: ba.author.name,
        order_by_name: ba.author.order_by_name,
        is_icelandic: ba.author.is_icelandic,
        gender: ba.author.gender
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
