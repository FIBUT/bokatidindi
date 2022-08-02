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
          edit_admin_book_path(@resource.id),
          alert: 'Ekki var hægt að vista bókina.'
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
        admin_books_path,
        notice: "Bókin #{@resource.title} hefur verið uppfærð."
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
  filter :publisher
  filter :id_equals

  index do
    selectable_column
    column :title do |book|
      link_to book.full_title_noshy, admin_book_path(book)
    end
    column :publisher
    column :authors
    column :description, &:short_description
    column :created_at
    column :updated_at
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

  form do |f|
    f.semantic_errors

    f.inputs 'Titill' do
      f.input :pre_title,
              required: false,
              input_html: { autocomplete: 'off' },
              hint: 'Yfirfyrirsögn; t.d. nafn seríu; birtist fyrir ofan '\
                    'aðaltitil í mina letri.'
      f.input :title,
              required: true,
              input_html: { autocomplete: 'off' },
              hint: 'Aðaltitill bókarinnar; birtist sem aðalfyrirsögn. Hægt '\
                    'er að nota táknið | til að stilla af línuskiptingar '\
                    'fyrir löng orð á minni skjám.'
      f.input :post_title,
              required: false,
              input_html: { autocomplete: 'off' },
              hint: 'Undirfyrirsögn; biritist fyrir neðan aðaltitil í minna '\
                    'letri.'
    end

    f.has_many :book_authors, heading: 'Höfundar', allow_destroy: true do |ba|
      ba.input :author_type,
               input_html: { autocomplete: 'off' }
      ba.input :author, input_html: { autocomplete: 'off' }
    end

    f.inputs 'Lýsing' do
      f.input :description,
              as: :string,
              required: true,
              input_html: { rows: 2, autocomplete: 'off' },
              hint: 'Stutt lýsing á bók, sem birtist á yfirlittsíðu og í '\
                    'prentútgáfu Bókatíðinda. Hámark 300 slög.'
      f.input :long_description,
              as: :text,
              input_html: { rows: 5, autocomplete: 'off' },
              hint: 'Lengri lýsing sem birtist á upplýsingasíðu hverrar bókar '\
                    'í vefútgáfu. Ef þessi reitur er tómur birtist styttri '\
                    'lýsingin í staðinn.'
    end

    f.inputs 'Vefslóðir' do
      f.input :uri_to_audiobook, input_html: { autocomplete: 'off' }
      f.input :uri_to_buy, input_html: { autocomplete: 'off' }
    end

    f.inputs 'Nánari upplýsingar' do
      f.input :page_count
      f.input :minutes
      f.input :original_title, hint: 'Upprunalegur titill bókar ef erlend.'
      f.input(
        :country_of_origin,
        as: :country, include_blank: true,
        priority_countries: Book::PRIORITY_COUNTRIES_OF_ORIGIN,
        input_html: { autocomplete: 'off' },
        hint: 'Upprunaland bókar, ef erlend.'
      )
    end

    f.inputs 'Mynd af forsíðu' do
      if resource.cover_image.attached?
        f.img src: resource.cover_image_variant_url(266), class: 'cover-image'
      end
      f.input :cover_image_file, as: :file
    end

    f.has_many(
      :book_binding_types, heading: 'Bindingar og útgáfur', allow_destroy: true
    ) do |bb|
      bb.input :binding_type, collection: BindingType.open
      bb.input :barcode, input_html: { autocomplete: 'off' }
    end

    f.has_many :book_categories, heading: 'Flokkar', allow_destroy: true do |bc|
      bc.input :category,
               include_blank: true,
               member_label: :name_with_group,
               input_html: { autocomplete: 'off' }
    end

    if Edition.active.count.positive?
      f.inputs do
        f.input :editions, as: :check_boxes, collection: Edition.active
      end
    end

    if current_admin_user.admin?
      f.inputs 'Ítarupplýsingar (eingöngu fyrir FÍBÚT)' do
        f.input :source_id,
                input_html: { autocomplete: 'off' },
                hint: 'Upprunalegt raðnúmer bókar úr eldra kerfi FÍBÚT.'
        f.input :publisher,
                input_html: { autocomplete: 'off' }
      end
    end

    f.actions
  end
end
