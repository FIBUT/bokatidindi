# frozen_string_literal: true

ActiveAdmin.register Edition do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :original_title_id_string, :active
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :original_title_id_string, :active]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :title, :opening_date, :online_date, :closing_date, :print_date

  config.filters = false

  index do
    selectable_column
    column :title do |edition|
      link_to edition.title, admin_edition_path(edition)
    end
    column :opening_date
    column :online_date
    column :closing_date
    column :print_date
    column :book_count, &:book_count
    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Titill' do
      f.input :title
    end

    f.inputs 'Dagsetningar' do
      f.input :opening_date
      f.input :online_date
      f.input :closing_date
      f.input :print_date
    end

    f.actions
  end
end
