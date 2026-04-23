# frozen_string_literal: true

ActiveAdmin.register Tag do
  config.sort_order = 'rod_asc'
  permit_params :title, :title_plural, :slug, :description, :active, :rod
end
