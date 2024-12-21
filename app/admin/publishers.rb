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

  permit_params :name, :kennitala, :email_address, :url

  filter :name_contains

  member_action :invoice, method: :post do
    render status: :unauthorized unless current_admin_user.admin?

    dk_invoice_number = resource.create_dk_invoice_by_edition_id!(
      Edition.current_edition.id
    )

    unless dk_invoice_number
      return redirect_to resource_path,
                         notice: 'Invoice was not created due to an error.'
    end

    redirect_to resource_path,
                notice: "Invoice #{dk_invoice_number} was created."
  end

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
    column :kennitala
    column :email_address
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
    div do
      if current_admin_user.admin? && !ENV.key?('DK_API_KEY')
        para 'API-lykill fyrir DK hefur ekki verið settur inn. '\
             'DK-tengingin er því óvirk.'
      end
    end
    panel 'Upplýsingar um útgefanda' do
      attributes_table_for publisher do
        row :name
        row :kennitala
        row :email_address
        row :url
        row :is_in_dk, &:in_dk?
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
          column :invoiced
          column :dk_invoice_number
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
          tr class: 'invoiced_count' do
            td class: 'th' do
              'Fjöldi birtinga á reikning'
            end
            td class: 'value' do
              publisher.book_edition_categories_by_edition_id(
                e.id
              ).invoiced.count
            end
          end
        end
        if ENV.key?('DK_API_KEY') &&
           publisher.in_dk? &&
           Edition.current_edition == e &&
           current_admin_user.admin? &&
           !publisher.book_edition_categories_by_edition_id(
             e.id
           ).uninvoiced.empty?
          form class: 'dk-invoice-button-container', method: :post,
               action: "/admin/publishers/#{publisher.id}/invoice" do
            input name: 'authenticity_token', type: :text,
                  value: form_authenticity_token
            input type: :submit, value: 'Búa til reikning í DK'
            para 'Reikningar eru útbúnir til fyrir birtingar sem hafa ekki '\
                'verið skráðar sem settar á reikning áður'
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Upplýsingar um útgefanda' do
      f.input :name
      f.input :kennitala
      f.input :email_address
      f.input :url
    end

    f.actions
  end
end
