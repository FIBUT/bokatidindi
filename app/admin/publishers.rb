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

  permit_params :name, :email_address, :url

  filter :name_contains

  controller do
    def build_new_resource
      super.tap do |r|
        r.assign_attributes(
          url: 'https://'
        )
      end
    end
  end

  index do
    selectable_column
    column :name do |publisher|
      link_to publisher.name, admin_publisher_path(publisher)
    end
    column :email_address
    column :url
    column :book_count
    column :print_data do |publisher|
      unless publisher.book_count.zero?
        link_to(
          'Sækja prentgögn',
          "/xml_feeds/editions_for_print/current?publisher_id=#{publisher.id}"
        )
      end
    end
    actions
  end

  show do
    panel 'Upplýsingar um útgefanda' do
      attributes_table_for publisher do
        row :name
        row :email_address
        row :url
      end
    end
    Edition.current.each do |e|
      panel e.title do
        table_for(
          publisher.book_edition_categories_by_edition_id(e.id),
          class: 'publisher_book_edition_categories'
        ) do
          column(:book, &:book)
          column :category
          column :for_web
          column :for_print
          column :created_at
          column :updated_at
        end

        table class: 'publisher_book_edition_category_totals' do
          tr class: 'web_count' do
            td class: 'th' do
              'Fjöldi birtinga á vef'
            end
            td class: 'value' do
              publisher.book_edition_categories_by_edition_id(
                e.id
              ).where(
                for_web: true
              ).count
            end
          end
          tr class: 'print_count' do
            td class: 'th' do
              'Fjöldi birtinga á prenti'
            end
            td class: 'value' do
              publisher.book_edition_categories_by_edition_id(
                e.id
              ).where(
                for_print: true
              ).count
            end
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Upplýsingar um útgefanda' do
      f.input :name
      f.input :email_address
      f.input :url
    end

    f.actions
  end
end
