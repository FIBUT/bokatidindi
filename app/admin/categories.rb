# frozen_string_literal: true

ActiveAdmin.register Category do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :source_id, :origin_name, :slug, :rod, :super_category
  #
  # or
  #
  # permit_params do
  #   permitted = [:source_id, :origin_name, :slug, :rod, :super_category]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :name, :group, :rod

  config.filters = false
  config.sort_order = 'rod_asc'

  index do
    selectable_column
    column :name do |category|
      link_to category.name, admin_category_path(category)
    end
    column :group do |category|
      unless category.group.nil?
        I18n.t("activerecord.attributes.category.groups.#{category.group}")
      end
    end
    column :book_count, &:book_count
    column :book_count_web, &:book_count_web
    column :book_count_print, &:book_count_print
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :group
    end
    f.actions
  end
end
