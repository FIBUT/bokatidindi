# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    build_xml pages + books + categories + authors + publishers
  end

  def pages_feed
    build_xml pages
  end

  def books_feed
    build_xml books
  end

  def categories_feed
    build_xml categories
  end

  def authors_feed
    build_xml authors
  end

  def publishers_feed
    build_xml publishers
  end

  private

  def build_xml(records)
    builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
      xml.urlset(
        'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
        'xmlns:image' => 'http://www.google.com/schemas/sitemap-image/1.1'
      ) do
        records.each do |r|
          xml.url do
            xml.loc r[:loc]
            xml.lastmod r[:lastmod]
            xml.priority r[:priority]
            xml.changefreq r[:changefreq]
            if r[:image]
              xml.send 'image:image' do
                xml.send 'image:loc', r[:image]
              end
            end
          end
        end
      end
    end

    render xml: builder.to_xml
  end

  def pages
    urls = []

    Page.find_each do |p|
      urls << {
        loc: "https://www.bokatidindi.is/pages/#{p.slug}",
        lastmod: p.updated_at.time.iso8601,
        priority: 0.5,
        changefreq: 'yearly'
      }
    end

    urls
  end

  def books
    books = Book.order(created_at: :asc)
    urls  = []

    books.each do |b|
      urls << book_hash(b)
    end

    urls
  end

  def book_hash(book)
    hash = {
      loc: "https://www.bokatidindi.is/bok/#{book.slug}",
      lastmod: book.updated_at.time.iso8601,
      priority: book_priority_from_date(book),
      changefreq: book_changefreq_from_date(book)
    }
    return hash unless book.cover_image.attached?

    hash[:image] = Book.last.cover_image_variant_url(550)

    hash
  end

  def categories
    categories = Category.order(rod: :asc).includes(:books)
    urls       = []

    urls << {
      loc: 'https://www.bokatidindi.is/baekur/',
      lastmod: Book.last.updated_at.time.iso8601,
      priority: 0.3,
      changefreq: 'weekly'
    }

    categories.each do |c|
      next if c.books.current.empty?

      urls << {
        loc: "https://www.bokatidindi.is/baekur/flokkur/#{c.slug}",
        lastmod: c.books.current.last.updated_at.time.iso8601,
        priority: 0.8,
        changefreq: 'weekly'
      }
    end

    urls
  end

  def authors
    urls = []

    Author.find_each do |a|
      urls << {
        loc: "https://www.bokatidindi.is/baekur/hofundur/#{a.slug}",
        lastmod: a.updated_at.time.iso8601,
        priority: author_priority_from_books(a),
        changefreq: 'yearly'
      }
    end

    urls
  end

  def publishers
    urls = []

    Publisher.find_each do |p|
      urls << {
        loc: "https://www.bokatidindi.is/baekur/utgefandi/#{p.slug}",
        lastmod: p.updated_at.time.iso8601,
        priority: 0.5,
        changefreq: 'monthly'
      }
    end

    urls
  end

  def category_priority_from_date(collection)
    collection.books.order(updated_at: :asc).first.updated_at.time.iso8601
  end

  def book_priority_from_date(record)
    case Time.zone.now - record.created_at
    when 0..1.year.in_seconds
      0.7
    when (1.year.in_seconds..)
      0.2
    else
      0.5
    end
  end

  def author_priority_from_books(record)
    book_count = record.book_authors.where(
      'book_authors.created_at >= :start_date AND '\
      'book_authors.created_at <= :end_date',
      {
        start_date: 1.year.ago.to_fs(:db),
        end_date: Time.zone.now.to_fs(:db)
      }
    ).count

    case book_count
    when 0
      0.2
    else
      0.8
    end
  end

  def publisher_priority_from_books(record)
    book_count = record.books.where(
      'book_authors.updated_at >= :start_date AND '\
      'book_authors.updated_at <= :end_date',
      {
        start_date: 1.year.ago.to_fs(:db),
        end_date: Time.zone.now.to_fs(:db)
      }
    ).count

    case book_count
    when 0
      0.2
    else
      0.8
    end
  end

  def book_changefreq_from_date(record)
    case Time.zone.now - record.created_at
    when 0..7.days.in_seconds
      'daily'
    when 7.days.in_seconds..1.month.in_seconds
      'weekly'
    when 1.month.in_seconds..2.years.in_seconds
      'yearly'
    else
      'never'
    end
  end
end
