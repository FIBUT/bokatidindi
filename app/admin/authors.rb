# frozen_string_literal: true

ActiveAdmin.register Author do
  config.sort_order = 'order_by_name_asc'

  permit_params :firstname, :lastname, :gender, :is_icelandic

  filter :firstname_contains
  filter :lastname_contains

  index do
    selectable_column
    column :name do |author|
      link_to author.name, admin_author_path(author)
    end
    column :gender do |author|
      unless author.gender.nil?
        I18n.t("activerecord.attributes.author.genders.#{author.gender}")
      end
    end
    column :is_icelandic
    column :book_count, &:book_count
    actions
  end

  show do
    panel 'Upplýsingar um höfund' do
      attributes_table_for author do
        row :name, &:name
        row :book_count, &:book_count
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Nafn' do
      f.input :firstname
      f.input :lastname
      f.input(
        :is_icelandic,
        label: 'Höfundur er íslenskur'
      )
      f.input :gender, include_blank: false
    end

    f.actions
  end
end
