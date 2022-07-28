# frozen_string_literal: true

class AddOpeningAndClosingDatesToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :print_date, :datetime, after: :active
    add_column :editions, :closing_date, :datetime, after: :active
    add_column :editions, :opening_date, :datetime, after: :active

    bt2022 = Edition.find_by(original_title_id_string: 'BT2022')

    bt2022.print_date   = Date.new(2022, 10, 1)
    bt2022.closing_date = Date.new(2022, 9, 1)
    bt2022.opening_date = Date.new(2022, 1, 1)
    bt2022.save

    bt2021 = Edition.find_by(original_title_id_string: 'BT2021')

    bt2021.print_date   = Date.new(2021, 10, 1)
    bt2021.closing_date = Date.new(2021, 9, 1)
    bt2021.opening_date = Date.new(2021, 1, 1)
    bt2021.save
  end
end
