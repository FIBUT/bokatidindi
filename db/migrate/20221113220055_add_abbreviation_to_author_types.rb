# frozen_string_literal: true

class AddAbbreviationToAuthorTypes < ActiveRecord::Migration[7.0]
  def up
    add_column :author_types, :abbreviation, :string
    role_abbrebiations = { '2' => 'Höf', '5' => 'Þýð', '4' => 'Myndir',
                           '1' => 'Myndh', '7' => 'Les', '9' => 'Endurs',
                           '10' => 'Skrás', '8' => 'Umsj', '6' => 'Ristj',
                           '3' => 'Mndrtstj', '11' => 'Ljóð', '12' => 'Þýð.lj' }

    AuthorType.all.find_each do |at|
      next unless role_abbrebiations.key? at.id.to_s

      at.abbreviation = role_abbrebiations[at.id.to_s]
      at.save
    end
  end

  def down
    remove_column :author_types, :abbreviation
  end
end
