# frozen_string_literal: true

ActiveAdmin.register AuthorType do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :source_id, :name, :slug, :rod
  #
  # or
  #
  # permit_params do
  #   permitted = [:source_id, :name, :slug, :rod]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  permit_params :name, :plural_name, :abbreviation, :schema_role, :rod

  config.sort_order = 'rod_asc'
  config.filters = false

  index do
    selectable_column
    column :name do |author_type|
      link_to author_type.name, admin_author_type_path(author_type)
    end
    column :plural_name
    column :abbreviation
    column :schema_role
    column :rod
    actions
  end

  show do
    panel 'Upplýsingar um hlutverk' do
      attributes_table_for author_type do
        row :name
        row :plural_name
        row :abbreviation
        row :schema_role
        row :rod
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Upplýsingar um hlutverk' do
      f.input :name
      f.input :plural_name
      f.input :abbreviation
      f.input :schema_role, include_blank: true
      f.input :rod
    end

    f.actions
  end
end
