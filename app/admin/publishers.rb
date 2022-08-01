# frozen_string_literal: true

ActiveAdmin.register Publisher do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :source_id, :name, :slug, :url
  #
  # or
  #
  # permit_params do
  #   permitted = [:source_id, :name, :slug, :url]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  config.sort_order = 'name_asc'

  permit_params :name, :url

  filter :name_contains

  index do
    selectable_column
    column :name do |publisher|
      link_to publisher.name, admin_publisher_path(publisher)
    end
    column :url
    column :book_count, &:book_count
    actions
  end

  show do
    panel 'Upplýsingar um útgefanda' do
      attributes_table_for publisher do
        row :name
        row :url
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Upplýsingar um útgefanda' do
      f.input :name
      f.input :url
    end

    f.actions
  end
end
