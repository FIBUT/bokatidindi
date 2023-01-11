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
    where(
      "opening_date < '#{DateTime.now.to_fs(:db)}' "\
      "AND closing_date > '#{DateTime.now.to_fs(:db)}'"\
    )
  }

  scope :frozen, lambda {
    where(
      "closing_date < '#{DateTime.now.to_fs(:db)}' and "\
      "print_date > '#{DateTime.now.to_fs(:db)}'"
    )
  }

  scope :inactive, lambda {
    where.not(
      id: Edition.current.ids
    )
  }

  # Editions that are currently visible online
  scope :current, lambda {
    where(
      "online_date < '#{DateTime.now.to_fs(:db)}'"
    ).order(id: :desc).limit(1)
  }

  scope :active_for_web_only, lambda {
    where(
      "opening_date >= '#{Edition.current.first.opening_date.to_fs(:db)}' and "\
      "print_date < '#{DateTime.now.to_fs(:db)}'"
    )
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

  def active?
    Edition.active.ids.include?(id)
  end

  def frozen?
    return false if closing_date.nil? || print_date.nil?
    # "closing_date < '#{DateTime.now.to_fs(:db)}' and "\
    # "print_date > '#{DateTime.now.to_fs(:db)}'"
    return false unless closing_date < DateTime.now && print_date > DateTime.now

    true
  end

  def self.form_collection(include_frozen = false)
    editions = if include_frozen
                 (Edition.active + Edition.frozen + Edition.active_for_web_only)
               else
                 (Edition.active + Edition.active_for_web_only)
               end

    form_collection = []
    editions.uniq.each do |e|
      form_collection << [e.form_label, e[:id]]
    end

    form_collection
  end

  def form_label
    if frozen?
      return "#{title} "\
             '(skráningar eru frystar og eingöngu aðgengilegar stjórnendum)'
    end
    if print_registration_over?
      return "#{title} (lokað fyrr skráningu í prentútgáfu)"
    end

    title
  end

  def print_registration_over?
    true if print_date < DateTime.now
  end

  def self.current_edition
    Edition.where(
      "online_date < '#{DateTime.now.to_fs(:db)}'"
    ).order(id: :desc).limit(1).first
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      book_editions: { 'edition_id': id }
    ).count
  end
end
