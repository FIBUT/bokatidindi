# frozen_string_literal: true

ActiveAdmin.register Book do
  permit_params :id, :pre_title, :title, :post_title,
                :description, :long_description,
                :country_of_origin, :original_title,
                :cover_image_file,
                :publisher_id,
                {
                  book_binding_types_attributes: %i[
                    id barcode binding_type_id language page_count
                    minutes url _destroy
                  ],
                  book_authors_attributes: %i[
                    id author_type_id author_id _destroy
                  ],
                  edition_ids: [], category_ids: []
                }

  controller do
    def build_new_resource
      super.tap do |r|
        if current_admin_user.publisher?
          r.assign_attributes(
            publisher_id: current_admin_user.publisher_ids.first
          )
        end
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

      # Check if the current can update the book resource, as is.
      authorize! :update, @resource

      # Update the book resource with the form data.
      @resource.assign_attributes(permitted_params[:book])

      # If the publisher_id attribute is not specified in the form, we should
      # assign it to the current user's first (and presumabily only publisher).
      if !permitted_params[:book][:publisher_id] &&
         current_admin_user.publisher?
        return bad_request if current_admin_user.publisher_ids.count.zero?

        @resource[:publisher_id] = current_admin_user.publisher_ids.first
      end

      # Do a second access check on the book, in case something changed
      authorize! :update, @resource

      # Get the IDs of the current inactive editions for preservation.
      inactive_edition_ids = @resource.editions.inactive.pluck(:id)

      unless @resource.save
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

      # Upload the attached image file, if any.
      if permitted_params[:book][:cover_image_file]
        content_type = permitted_params[:book][:cover_image_file].content_type

        if Book::PERMITTED_IMAGE_FORMATS.include?(content_type)
          cover_image_contents = permitted_params[:book][:cover_image_file].read
          @resource.attach_cover_image_from_string cover_image_contents
        end
      end

      # Confirm success.
      redirect_to(
        admin_books_path,
        notice: "Bókin #{@resource.title} hefur verið uppfærð."
      )
    end

    def create
      @resource = Book.new(permitted_params[:book].except(:cover_image_file))

      authorize! :create, @resource

      unless @resource.save
        redirect_to(
          new_admin_book_path,
          alert: 'Ekki var hægt að skrá bókina.'
        )
      end

      @resource.reload

      if permitted_params[:book][:cover_image_file]
        cover_image_contents = permitted_params[:book][:cover_image_file].read
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

    publishers = Publisher.all if current_admin_user.admin?
    publishers = current_admin_user.publishers if current_admin_user.publisher?

    if publishers.count > 1
      f.inputs 'Útefandi' do
        f.input :publisher,
                collection: publishers,
                include_blank: false,
                input_html: { autocomplete: 'off' }
      end
    end

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
      ba.input(
        :author,
        collection: Author.order(:name)
      )
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

    f.inputs 'Mynd af forsíðu' do
      if resource.cover_image.attached?
        f.img src: resource.cover_image_variant_url(266), class: 'cover-image'
      end
      f.input(
        :cover_image_file,
        as: :file,
        hint: 'Tekið er við myndum á sniðunum JPEG, PNG, WebP, TIFF, '\
              'JPEG 2000 og JPEG XL. Myndir eru unnar sjálfkrafa yfir í '\
              'viðeigandi snið fyrir vef og prent við skráningu.'
      )
    end

    f.has_many(
      :book_binding_types, heading: 'Útgáfuform', allow_destroy: true
    ) do |bb|
      bb.input(
        :binding_type,
        collection: BindingType.open, input_html: { class: 'binding-type' }
      )
      bb.input(
        :barcode,
        input_html: { autocomplete: 'off', class: 'barcode' }
      )
      bb.input(
        :language,
        collection: BookBindingType::AVAILABLE_LANGUAGES.map do |l|
          ["#{l[0]} - #{I18n.t("languages.#{l[0]}")}", l[0]]
        end,
        input_html: { autocomplete: 'off', class: 'language' }
      )
      bb.input(
        :page_count,
        input_html: { autocomplete: 'off', min: 1, class: 'page-count' }
      )
      bb.input(
        :minutes,
        input_html: { autocomplete: 'off', min: 1, class: 'minutes' }
      )
      bb.input(
        :url,
        input_html: { autocomplete: 'off', class: 'url' }
      )
    end

    f.inputs do
      f.input(
        :categories,
        as: :check_boxes,
        collection: Category.all,
        member_label: :name_with_group
      )
    end

    if Edition.active.count.positive?
      f.inputs do
        f.input :editions, as: :check_boxes, collection: Edition.active
      end
    end

    f.inputs 'Nánari upplýsingar' do
      f.input :original_title, hint: 'Upprunalegur titill bókar ef erlend.'
      f.input(
        :country_of_origin,
        as: :country, include_blank: true,
        priority_countries: Book::PRIORITY_COUNTRIES_OF_ORIGIN,
        input_html: { autocomplete: 'off' },
        hint: 'Upprunaland bókar, ef erlend.'
      )
    end

    f.actions
  end
end
