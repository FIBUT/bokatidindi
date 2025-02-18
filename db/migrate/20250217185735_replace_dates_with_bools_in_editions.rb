class ReplaceDatesWithBoolsInEditions < ActiveRecord::Migration[7.0]
  def up
    add_column :editions, :online, :boolean, default: false
    add_column :editions, :open_to_web_registrations, :boolean, default: false
    add_column :editions, :open_to_print_registrations, :boolean, default: false

    add_index :editions, :online
    add_index :editions, :open_to_web_registrations
    add_index :editions, :open_to_print_registrations

    current_edition = Edition.current_edition
    current_edition[:online] = true
    current_edition.save

    last_edition = Edition.last
    last_edition[:open_to_web_registrations] = true
    last_edition[:open_to_print_registrations] = true
    last_edition.save

    # remove_column :editions, :opening_date
    # remove_column :editions, :online_date
    # remove_column :editions, :closing_date
  end

  def down
    remove_column :editions, :online
    remove_column :editions, :open_to_web_registrations
    remove_column :editions, :open_to_print_registrations
  end
end
