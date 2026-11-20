# frozen_string_literal: true

ActiveAdmin.register Tag do
  config.sort_order = 'rod_asc'
  permit_params :title, :title_plural, :slug, :description, :active, :rod

  config.sort_order = 'rod_asc'

  index do
    selectable_column

    column :title do |tag|
      link_to tag.title, edit_admin_tag_path(tag)
    end

    column :title_plural
    column :slug
    column :description
    column :rod

    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :title
      f.input :title_plural
      f.input :slug
      f.input :rod
    end

    f.actions
  end
end
