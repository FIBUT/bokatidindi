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
  config.sort_order = 'rod_asc'

  permit_params :name, :rod, :open, :group

  controller do
    def build_new_resource
      super.tap do |r|
        r.assign_attributes(rod: 1, open: true)
      end
    end
  end

  index do
    selectable_column
    column :name do |binding_type|
      link_to binding_type.name, admin_binding_type_path(binding_type)
    end
    column :group do |binding_type|
      unless binding_type.group.nil?
        I18n.t(
          "activerecord.attributes.binding_type.groups.#{binding_type.group}"
        )
      end
    end
    column :rod
    column :open
    column :book_count, &:book_count
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :group
      f.input :rod
      f.input :open
    end
    f.actions
  end
end
