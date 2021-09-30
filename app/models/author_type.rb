class AuthorType < ApplicationRecord
  PLURALS = {
    'Höfundur': 'Höfundar',
    'Þýðandi': 'Þýðendur',
    'Ritstjóri': 'Ritsjórar'
  }.freeze

  def plural_name
    return name unless AuthorType::PLURALS.key?(name.to_sym)

    AuthorType::PLURALS[name.to_sym]
  end
end
