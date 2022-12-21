# frozen_string_literal: true

ActiveAdmin.register Edition do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :original_title_id_string, :active
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :original_title_id_string, :active]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :title, :opening_date, :online_date, :closing_date, :print_date,
                :cover_image_file, :pdf_file, :is_legacy, :year,
                :delete_cover_image_file, :delete_pdf_file

  config.filters = false

  index do
    selectable_column
    column :title do |edition|
      link_to edition.title, admin_edition_path(edition)
    end
    column :opening_date
    column :online_date
    column :closing_date
    column :print_date
    column :book_count, &:book_count
    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Titill' do
      f.input :title
    end

    f.inputs 'Forsíðumynd' do
      if @resource.cover_image.attached?
        img src: @resource.cover_image_variant_url(150, 'jpg')
        f.input :delete_cover_image_file, as: :boolean
      else
        f.input :cover_image_file, as: :file
      end
    end

    f.inputs 'PDF-skjal' do
      if @resource.pdf_file.attached?
        para link_to f.resource.pdf_file_url
        f.input :delete_pdf_file, as: :boolean
      else
        f.input :pdf_file, as: :file
      end
    end

    f.inputs 'Stillingar fyrir eldri tölublöð' do
      f.input :year
      f.input :is_legacy
    end

    f.inputs 'Dagsetningar' do
      f.input :opening_date
      f.input :online_date
      f.input :closing_date
      f.input :print_date
    end

    f.actions
  end

  controller do
    def create
      super

      if edition_form[:cover_image_file]
        cover_image_contents = edition_form[:cover_image_file].read

        cover_image_content_type = MimeMagic.by_magic(cover_image_contents).type

        if Edition::PERMITTED_IMAGE_FORMATS.include?(cover_image_content_type)
          resource.attach_cover_image_from_string(cover_image_contents)
        end
      end

      SetEditionImageVariantsJob.set(wait: 20).perform_later resource
    end

    def update
      super

      edition_form = permitted_params[:edition]

      if edition_form[:delete_cover_image_file] == '1'
        resource.cover_image.destroy
        resource.cover_image_srcsets = ''
      end

      resource.pdf_file.destroy if edition_form[:delete_pdf_file] == '1'

      if edition_form[:cover_image_file]
        cover_image_contents = edition_form[:cover_image_file].read

        cover_image_content_type = MimeMagic.by_magic(cover_image_contents).type

        if Edition::PERMITTED_IMAGE_FORMATS.include?(cover_image_content_type)
          resource.attach_cover_image_from_string(cover_image_contents)
        end
      end

      SetEditionImageVariantsJob.set(wait: 20).perform_later resource
    end
  end
end
