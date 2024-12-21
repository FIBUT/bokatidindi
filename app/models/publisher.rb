# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :books, dependent: :restrict_with_error

  before_create :set_slug

  default_scope { order(:name) }

  validates :url, url: true, allow_blank: true
  validates :email_address, format: { with: Devise.email_regexp },
                            allow_blank: true

  def book_edition_categories_by_edition_id(edition_id)
    BookEditionCategory.joins(
      book_edition: [book: [:publisher]]
    ).where(
      'books.publisher_id': id, 'book_editions.edition.id': edition_id
    )
  end

  def in_dk?
    return nil unless ENV.key?('DK_API_KEY')

    return nil unless kennitala

    api_key = ENV['DK_API_KEY']

    uri = URI "https://api.dkplus.is/api/v1/customer/#{kennitala}"

    response = Net::HTTP.get_response(uri, api_headers(api_key))

    return false unless response.instance_of? Net::HTTPOK

    true
  end

  def create_dk_invoice_by_edition_id!(edition_id)
    return nil unless ENV.key?('DK_API_KEY')

    return nil unless kennitala

    api_key = ENV['DK_API_KEY']

    to_be_invoiced = book_edition_categories_by_edition_id(edition_id).uninvoiced

    return nil if to_be_invoiced.empty?

    invoice_hash = dk_invoice(to_be_invoiced)

    return nil unless invoice_hash

    return nil if invoice_hash[:Lines].empty?

    uri = URI 'https://api.dkplus.is/api/v1/Sales/Invoice'

    response = Net::HTTP.post(uri, invoice_hash.to_json, api_headers(api_key))

    return nil unless response.instance_of? Net::HTTPOK

    reponse_json = JSON.parse(response.body)

    return nil unless reponse_json.key? 'Number'

    dk_invoice_number = reponse_json['Number']

    to_be_invoiced.update_all({ invoiced: true,
                                dk_invoice_number: dk_invoice_number })

    dk_invoice_number
  end

  def dk_invoice(to_be_invoiced)
    return nil if to_be_invoiced.empty?

    return nil unless kennitala

    {
      Customer: { Number: kennitala },
      SalesPerson: ENV['DK_SALES_PERSON'] || 'websales',
      Lines: prepare_dk_invoice_lines(to_be_invoiced),
      Term: ENV['DK_SALES_TERM'] || 'M20',
      Options: { OriginalPrices: true }
    }
  end

  def book_count
    Book.includes(
      :book_editions
    ).where(
      publisher_id: id,
      book_editions: { 'edition_id': Edition.current_edition[:id] }
    ).count
  end

  private

  def api_headers(api_key)
    { 'Content-Type': 'application/json',
      'Authorization': "Bearer #{api_key}" }
  end

  def prepare_dk_invoice_lines(to_be_invoiced)
    invoice_lines = []

    to_be_invoiced.find_each do |tbi|
      invoice_lines.concat tbi.to_dk_invoice_lines
    end

    invoice_lines
  end

  def set_slug
    self.slug = name.parameterize(locale: :is)
  end
end
