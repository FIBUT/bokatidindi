# frozen_string_literal: true

ActiveAdmin.register BindingType do
  config.filters = false
  config.sort_order = 'rod_asc'

  permit_params :name, :rod, :open, :group, :barcode_type

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
      f.input :barcode_type, include_blank: false
      f.input :group, include_blank: false
      f.input :rod
      f.input :open
    end
    f.actions
  end
end
