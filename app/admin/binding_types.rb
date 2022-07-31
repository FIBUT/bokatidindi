# frozen_string_literal: true

ActiveAdmin.register BindingType do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :source_id, :name, :slug, :rod, :open
  #
  # or
  #
  # permit_params do
  #   permitted = [:source_id, :name, :slug, :rod, :open]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  config.filters = false

  index do
    selectable_column
    column :source_id
    column :name
    column :rod
    column :open
    column :book_count, &:book_count
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :rod
      f.input :open
    end
    f.actions
  end
end
