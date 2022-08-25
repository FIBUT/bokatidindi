# frozen_string_literal: true

class XmlFeedsController < ApplicationController
  def edition_for_print
    edition = if params[:id] == 'current'
                Edition.current.last
              else
                Edition.find(params[:id])
              end
    categories = books_by_category(edition[:id])

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.edition do
        xml.id edition[:id]
        xml.title edition[:title]
        xml.categories do
          categories.each do |c|
            xml.category do
              xml.group c[:group]
              xml.name c[:name]
              xml.books do
                c[:books].each do |b|
                  xml.book do
                    xml.id b[:id]
                    xml.slug b[:slug]
                    xml.pre_title b[:pre_title] unless b[:pre_title].empty?
                    xml.title b[:title_hypenated]
                    xml.post_title b[:post_title] unless b[:post_title].empty?
                    xml.description b[:description]
                    if b.cover_image?
                      xml.cover_image do
                        xml.url b.cover_image_url('jpeg')
                        xml.image href: "File:///cover_images/#{b[:slug]}.jpg"
                      end
                    end
                    xml.publisher do
                      xml.id b.publisher[:id]
                      xml.name b.publisher[:name]
                    end
                    xml.authors do
                      b.book_authors.order(id: :asc).each do |book_author|
                        xml.author do
                          xml.id book_author.author[:id]
                          xml.type book_author.author_type[:name]
                          xml.name book_author.author[:name]
                        end
                      end
                    end
                    xml.binding_types do
                      b.binding_types.order(rod: :asc).each do |binding_type|
                        xml.binding_type binding_type.name
                      end
                    end
                  end
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

  def books_by_category(edition_id = nil)
    edition_id = Edition.current[:id] if edition_id.nil?
    categories = []
    Category.order(rod: :asc).each do |c|
      categories << {
        id: c[:id],
        name: c[:name],
        group: I18n.t("activerecord.attributes.category.groups.#{c[:group]}"),
        books: Book.by_edition_and_category(
          edition_id, c[:id]
        ).order(title: :asc)
      }
    end
    categories
  end
end
