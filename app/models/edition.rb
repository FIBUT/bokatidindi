# frozen_string_literal: true

class Edition < ApplicationRecord
  PERMITTED_IMAGE_FORMATS = ['image/jpeg', 'image/png', 'image/webp',
                             'image/jp2', 'image/jxl', ' image/avif'].freeze

  COVER_IMAGE_VARIANTS = [150, 260, 550, 1200, 1600].freeze
  IMAGE_QUALITY        = 80

  include ActionView::Helpers::UrlHelper

  has_many :book_editions, dependent: :restrict_with_error
  has_many :book_edition_categories, through: :book_editions

  has_one_attached :cover_image, dependent: :destroy
  has_one_attached :pdf_file, dependent: :destroy

  # Editions that are open for registration
  scope :active, lambda {
    where(open_to_web_registrations: true)
  }

  scope :inactive, lambda {
    where(open_to_web_registrations: false)
  }

  # Editions that are currently visible online
  scope :current, lambda {
    where(online: true).order(id: :desc)
  }

  scope :old, lambda {
    where(online: false).order(id: :desc)
  }

  has_many :book_editions, dependent: :destroy
  has_many :books, through: :book_editions

  attribute :cover_image_file
  attribute :delete_cover_image_file
  attribute :pdf_file
  attribute :delete_pdf_file

  def attach_pdf_file_from_string(string)
    return false if pdf_file.attached?

    pdf_file.attach(io: StringIO.new(string), filename: SecureRandom.uuid)
  end

  def pdf_file_url
    return '' unless pdf_file.attached?

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(pdf_file)
    end

    pdf_file.url
  end

  def cover_image_url(image_format = 'webp')
    return '' unless cover_image.attached?

    cover_variant = cover_image.variant(format: image_format,
                                        saver: { quality: IMAGE_QUALITY })

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def cover_image_variant_url(width, image_format = 'webp')
    cover_variant = cover_image.variant(resize_to_limit: [width, nil],
                                        format: image_format,
                                        saver: { quality: IMAGE_QUALITY })

    if ActiveStorage::Blob.service.name.to_s == 'local'
      return Rails.application.routes.url_helpers.url_for(cover_variant)
    end

    cover_variant.processed.url
  end

  def attach_cover_image_from_string(string)
    return false if cover_image.attached?

    cover_image.attach(io: StringIO.new(string), filename: SecureRandom.uuid)

    attach_cover_image_variants
    true
  end

  def attach_cover_image_variants
    attach_cover_image_variant('webp')
    attach_cover_image_variant('jpg')
    COVER_IMAGE_VARIANTS.each do |v|
      attach_cover_image_variant('webp', v)
      attach_cover_image_variant('jpg', v)
    end
  end

  def attach_cover_image_variant(image_format, width = nil)
    if width
      return cover_image.variant(resize_to_limit: [width, width],
                                 format: image_format,
                                 saver: { quality: IMAGE_QUALITY }).process
    end
    cover_image.variant(format: image_format,
                        saver: { quality: IMAGE_QUALITY }).process
  end

  def update_cover_image_srcsets
    update_attribute(
      'cover_image_srcsets',
      { webp: cover_img_srcset('webp'), jpg: cover_img_srcset('jpg') }
    )
  end

  def cover_img_srcset(format = 'webp')
    return '' unless cover_image.attached?

    srcset = []
    COVER_IMAGE_VARIANTS.each do |v|
      srcset << cover_image_variant_url(v, format) + " #{v}w"
    end
    srcset.join(', ')
  end

  def self.form_collection
    Edition.where(open_to_web_registrations: true).map do |edition|
      [edition.form_label, edition.id]
    end
  end

  def form_label
    unless open_to_print_registrations
      return "#{title} (lokað fyrr skráningu í prentútgáfu)"
    end

    title
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      book_editions: { 'edition_id': id }
    ).count
  end
end
