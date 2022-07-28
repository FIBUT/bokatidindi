# frozen_string_literal: true

ActiveAdmin.register Book do
  permit_params do
    permitted = [
      :id, :pre_title, :title, :post_title, :description, :long_description,
      :cover_image_file, :uri_to_buy, :uri_to_audiobook,
      :page_count, :minutes, :original_title, :country_of_origin,
      { book_binding_types_attributes: %i[id barcode binding_type_id _destroy],
        book_authors_attributes: %i[id author_type_id author_id _destroy],
        book_categories_attributes: %i[id category_id _destroy],
        edition_ids: [] }
    ]
    if current_admin_user.admin?
      permitted << :source_id
      permitted << :publisher_id
    end
    permitted
  end

  controller do
    def build_new_resource
      super.tap do |r|
        r.assign_attributes(
          book_authors: [BookAuthor.new],
          book_binding_types: [BookBindingType.new],
          book_categories: [BookCategory.new],
          editions: Edition.active
        )
      end
    end

    def update
      @resource = Book.find(permitted_params[:id])

      # Get the IDs of the current inactive editions for preservation.
      inactive_edition_ids = @resource.editions.inactive.pluck(:id)

      unless @resource.update(permitted_params[:book])
        return redirect_to(
          edit_admin_book_path(
            @resource.id,
            notice: 'Ekki var hægt að vista bókina.'
          )
        )
      end

      @resource.reload

      # We want to retain the relationship to inactive editions.
      inactive_edition_ids.each do |edition_id|
        BookEdition.create(book_id: @resource.id, edition_id:)
      end

      if permitted_params[:book][:cover_image_file]
        cover_image_contents = permitted_params[:book][:cover_image_file].read
        @resource.attach_cover_image_from_string cover_image_contents
      end

      redirect_to(
        admin_book_path(
          @resource.id,
          notice: "Bókin #{@resource.title} hefur verið uppfærð."
        )
      )
    end

    def create
      @resource = Book.new(permitted_params[:book].except(:cover_image_file))

      if current_admin_user.publisher?
        @resource.publisher_id = current_admin_user.publisher_id
        @resource.source_id = nil
      end

      return nil unless @resource.save

      @resource.reload

      if permitted_params[:book][:cover_image_file]
        cover_image_contents  = permitted_params[:book][:cover_image_file].read
        @resource.attach_cover_image_from_string cover_image_contents
      end

      redirect_to(
        new_admin_book_path,
        notice: "Bókin #{@resource.title} hefur verið skráð."
      )
    end
  end

  filter :title_contains
  filter :description_contains
  filter :publishercheck
  filter :authors
  filter :id_equals

  index do
    selectable_column
    column :title do |book|
      link_to book.full_title_noshy, admin_book_path(book)
    end
    column :publisher
    column :authors, &:authors_brief
    column :description, &:short_description
    actions
  end

  show title: :full_title_noshy do
    panel 'Upplýsingar um bók' do
      attributes_table_for book do
        row 'Titill', &:title_noshy
        row :authors, &:authors_brief
        row :publisher
        row :categories do |book|
          book.categories.map(&:name_with_group)
        end
        row :show_description
        row :source_id
      end
    end
  end

  sidebar 'Mynd', only: :show do
    div do
      image_tag book.cover_image_url, width: 240, srcset: book.cover_img_srcset
    end
  end

  form partial: 'form'
end
