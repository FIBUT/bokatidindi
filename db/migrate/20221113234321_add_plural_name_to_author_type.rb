# frozen_string_literal: true

class AddPluralNameToAuthorType < ActiveRecord::Migration[7.0]
  def up
    add_column :author_types, :plural_name, :string

    plurals = { 'Höfundur' => 'Höfundar', 'Þýðandi' => 'Þýðendur',
                'Ritstjóri' => 'Ritstjórar' }.freeze

    AuthorType.all.find_each do |at|
      at.plural_name = if plurals.key? at.name
                         plurals[at.name]
                       else
                         at.name
                       end
      at.save
    end
  end

  def down
    remove_column :author_types, :plural_name
  end
end
