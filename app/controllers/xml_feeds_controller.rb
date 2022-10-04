# frozen_string_literal: true

class XmlFeedsController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  def edition_for_print
    edition = if params[:id] == 'current'
                Edition.current.last
              else
                Edition.find(params[:id])
              end

    categories = print_books_by_category(edition[:id], params[:publisher_id])

    builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
      dtd_path = if Rails.env.test?
                   Rails.root.join('public/edition.dtd').to_s
                 else
                   asset_url('edition.dtd')
                 end
      xml.doc.create_internal_subset('edition', nil, dtd_path)
      xml.edition do
        xml.edition_id edition[:id]
        xml.edition_title edition[:title]
        xml.categories do
          categories.each do |c|
            xml.category do
              xml.category_group c[:group]
              xml.category_name c[:name]
              xml.books do
                c[:books].each do |book|
                  book_markup(book, xml)
                end
              end
            end
          end
        end
      end
    end

    render xml: builder
  end

  private

  def book_markup(book, xml)
    xml.book do
      xml.book_id book[:id]
      xml.slug book[:slug]
      xml.pre_title book[:pre_title] unless book[:pre_title].empty?
      xml.title book[:title_hypenated]
      xml.post_title book[:post_title] unless book[:post_title].empty?
      xml.description do
        i = 0
        book.description_for_print.each_line(chomp: true) do |l|
          if i.zero?
            xml.description_firstline do
              xml << l
            end
          end
          unless i.zero?
            xml.description_more do
              xml << l
            end
          end
          i += 1
        end
      end
      if book.cover_image?
        # Two paths for the front cover are provided. The full URL for
        # retreiving each image from the CDN and the expected path it will be
        # located at for Adobe InDesign to use.
        xml.cover_image do
          xml.url book.print_image_variant_url
          xml.image href: "file:///cover_images/#{book[:slug]}.tiff"
        end
      end
      xml.publisher do
        xml.publisher_id book.publisher[:id]
        xml.publisher_name book.publisher[:name]
      end
      xml.authors do
        book.author_groups.each do |author_group|
          xml.author_group do
            xml.author_type author_group[:name]
            xml.author_names strip_tags(author_group[:author_links])
          end
        end
      end
      xml.binding_types do
        book.binding_types.order(rod: :asc).each do |binding_type|
          xml.binding_type binding_type.corrected_name
        end
      end
      xml.page_count book.page_count if book.page_count
      xml.hours book.hours if book.hours
    end
  end

  def print_books_by_category(edition_id = nil, publisher_id = nil)
    edition_id = Edition.current_edition[:id] if edition_id.nil?
    categories = []
    Category.order(rod: :asc).each do |c|
      books = Book.by_edition_and_category(
        edition_id, c[:id]
      ).order(title: :asc)

      books = books.where(publisher_id:) unless publisher_id.nil?

      next if books.empty?

      categories << {
        id: c[:id],
        name: c[:name],
        group: I18n.t("activerecord.attributes.category.groups.#{c[:group]}"),
        books:
      }
    end
    categories
  end
end
