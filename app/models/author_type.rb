# frozen_string_literal: true

class AuthorType < ApplicationRecord
  PLURALS = {
    'Höfundur': 'Höfundar',
    'Þýðandi': 'Þýðendur',
    'Ritstjóri': 'Ritstjórar'
  }.freeze

  def plural_name
    return name unless AuthorType::PLURALS.key?(name.to_sym)

    AuthorType::PLURALS[name.to_sym]
  end
end
