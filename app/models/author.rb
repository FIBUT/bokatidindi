# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :book_authors, dependent: :restrict_with_error
  has_many :books, through: :book_authors
  belongs_to :added_by, class_name: 'AdminUser'

  before_validation :strip_text
  before_validation :set_name
  before_create :set_slug, :set_order_by_name
  before_update :set_order_by_name

  validates :firstname, presence: true

  validate :lastname_has_to_be_set_if_not_admin

  def lastname_has_to_be_set_if_not_admin
    return nil unless lastname.empty? && added_by.role != 'admin'

    errors.add(
      :lastname,
      I18n.t('activerecord.errors.models.author.attributes.'\
             'lastname.has_to_be_set_if_not_admin')
    )
  end

  def book_count
    Book.includes(
      :book_editions, :book_authors, :authors
    ).where(
      book_authors: { authors: { id: } },
      book_editions: { 'edition_id': Edition.current_edition[:id] }
    ).count
  end

  def set_order_by_name
    return self.order_by_name = firstname if lastname.empty?

    if is_icelandic == true
      return self.order_by_name = "#{firstname} #{lastname}"
    end

    self.order_by_name = "#{lastname}, #{firstname}"
  end

  def set_name
    self[:name] = "#{firstname} #{lastname}"
  end

  def set_slug
    parameterized_name = name.parameterize(locale: :is).first(64)
    random_string = rand(1000..9999)

    # Prevent the slug from ending with a dash
    if parameterized_name.end_with?('-')
      parameterized_name = parameterized_name.chop
    end
    self.slug = "#{parameterized_name}-#{random_string}"
  end

  def strip_text
    self.firstname = firstname.try(:strip)
    self.lastname  = lastname.try(:strip)
  end

  def structured_data
    {
      '@type': 'Person',
      name: name,
      url: "https://www.bokatidindi.is/baekur/hofundur/#{slug}"
    }
  end
end
