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
                    minutes url availability publication_date _destroy
                  ],
                  book_authors_attributes: %i[
                    id author_type_id author_id _destroy
                  ],
                  book_categories_attributes: %i[
                    id category_id for_print for_web _destroy
                  ],
                  edition_ids: []
                }

  member_action :reset_categories do
    book_edition = resource.book_edition.where(
      edition_id: Edition.current_edition[:id]
    )
    book_edition.reset_book_edition_categories
    redirect_to resource_path, notice: 'Birtir flokkar hafa verið endurstilltir'
  end

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
          editions: Edition.active,
          country_of_origin: 'IS'
        )
      end
    end

    def update
      @resource = Book.find(permitted_params[:id])

      # Check if the current can update the book resource, as is.
      authorize! :update, @resource

      # Update the book resource with the form data.
      @resource.assign_attributes(
        permitted_params[:book].except(:edition_ids, :cover_image_file)
      )

      inactive_edition_ids = @resource.editions.inactive.pluck(:id)
      active_session_ids   = permitted_params[:book][:edition_ids]
      @resource.editions   = Edition.where(
        id: (inactive_edition_ids + active_session_ids)
      )

      # If the publisher_id attribute is not specified in the form, we should
      # assign it to the current user's first (and presumabily only publisher).
      if !permitted_params[:book][:publisher_id] &&
         current_admin_user.publisher?
        return bad_request if current_admin_user.publishers.count.zero?

        @resource[:publisher_id] = current_admin_user.publishers.first[:id]
      end

      # Do a second access check on the book, in case something changed
      authorize! :update, @resource

      @resource.validate

      if permitted_params[:book][:book_categories_attributes].values.count > 3
        @resource.errors.add(:book_categories, :too_many)
      end

      if permitted_params[:book][:cover_image_file]
        cover_image_contents = permitted_params[:book][:cover_image_file].read

        cover_image_content_type = MimeMagic.by_magic(cover_image_contents).type

        if Book::PERMITTED_IMAGE_FORMATS.include?(cover_image_content_type)
          cover_image_file_valid = true
        else
          @resource.errors.add(:cover_image_file, :invalid)
        end
      end

      if @resource.errors.none? && @resource.save
        if cover_image_file_valid
          @resource.attach_cover_image_from_string(cover_image_contents)
        end

        return redirect_to(
          admin_books_path,
          notice: "Bókin #{@resource.title} hefur verið uppfærð."
        )
      end

      render(:edit, alert: 'Ekki var hægt að vista bókina.')
    end

    def create
      @resource = Book.new(
        permitted_params[:book].except(
          :edition_ids, :cover_image_file
        )
      )

      if !permitted_params[:book][:publisher_id] &&
         current_admin_user.publisher?
        return bad_request if current_admin_user.publishers.count.zero?

        @resource[:publisher_id] = current_admin_user.publishers.first[:id]
      end

      inactive_edition_ids = @resource.editions.inactive.pluck(:id)
      active_session_ids   = permitted_params[:book][:edition_ids]
      @resource.editions   = Edition.where(
        id: (inactive_edition_ids + active_session_ids)
      )

      if permitted_params[:book][:cover_image_file]
        cover_image_contents = permitted_params[:book][:cover_image_file].read

        cover_image_content_type = MimeMagic.by_magic(cover_image_contents).type

        if Book::PERMITTED_IMAGE_FORMATS.include?(cover_image_content_type)
          cover_image_file_valid = true
        else
          @resource.errors.add(:cover_image_file, :invalid)
        end
      end

      authorize! :create, @resource

      @resource.validate

      if permitted_params[:book][:book_categories_attributes].values.count > 3
        @resource.errors.add(:book_categories, :too_many)
      end

      if @resource.errors.none? && @resource.save
        if cover_image_file_valid
          @resource.attach_cover_image_from_string(cover_image_contents)
        end

        return redirect_to(
          new_admin_book_path,
          notice: "Bókin #{@resource.title} hefur verið skráð."
        )
      end

      flash[:warn] = 'Ekki var hægt að skrá bókina.'
      render :new
    end
  end

  filter :title_contains
  filter :description_contains
  filter :publisher
  filter :id_equals

  includes :publisher, :authors

  index do
    selectable_column
    column :title do |book|
      link_to book.full_title_noshy, edit_admin_book_path(book)
    end
    column :publisher, sortable: 'publisher.name'
    column :authors
    column :description, &:short_description
    column :current_edition, &:current_edition?
    column :record_valid, &:valid?
    column :cover_image, &:cover_image?
    actions defaults: false do |book|
      unless book.editions.any?
        item 'Eyða', admin_book_path(book), method: 'delete',
                                            class: 'member_link'
      end
      item 'Skoða á vef', book_path(book[:slug]), target: '_blank',
                                                  class: 'member_link'
    end
  end

  show title: :full_title_noshy do
    panel 'Upplýsingar um bók' do
      attributes_table_for book do
        row 'Titill', &:title_noshy
        row :authors, &:authors_brief
        row :publisher
        row :categories
        row :description
        row :long_description
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
    f.semantic_errors(*f.object.errors.attribute_names)

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
              input_html: {
                autocomplete: 'off',
                maxlength: Book::TITLE_MAX_LENGTH
              },
              hint: 'Nafn ritraðar eða bókaflokks, t.d. „Lærdómsrit '\
                    'Bókmenntafélagsins“, „Risasyrpa“, „Dagbók Kidda '\
                    'Klaufa 15“ eða „Goðheimar 2“.'
      f.input :title,
              required: true,
              input_html: {
                autocomplete: 'off',
                maxlength: Book::TITLE_MAX_LENGTH
              },
              hint: 'Titill bókar. Hér má nota táknið | til að skipta '\
                    'orðum upp í orðhluta vegna birtingar á minni skjátækjum '\
                    'og fyrir prentvinnslu. Dæmi: „Brekku|kots|ann|áll“.'
      f.input :post_title,
              required: false,
              input_html: {
                autocomplete: 'off',
                maxlength: Book::TITLE_MAX_LENGTH
              }
    end

    f.has_many :book_authors, heading: 'Höfundar', allow_destroy: true do |ba|
      ba.input :author_type,
               input_html: { autocomplete: 'off' }
      ba.input(
        :author,
        collection: Author.order(:name),
        hint: 'Hvern og einn höfund, þýðanda, myndhöfund o.s.frv. þarf að '\
              'skrá í sitt hvoru lagi.'
      )
    end

    f.inputs 'Lýsing' do
      f.input :description,
              as: :string,
              required: true,
              input_html: {
                rows: 2,
                autocomplete: 'off',
                maxlength: Book::DESCRIPTION_MAX_LENGTH
              },
              hint: 'Stutt lýsing á bók, sem birtist á yfirlittsíðu og í '\
                    'prentútgáfu Bókatíðinda. '\
                    "Hámark #{Book::DESCRIPTION_MAX_LENGTH} slög."
      f.input :long_description,
              as: :text,
              input_html: {
                rows: 10,
                autocomplete: 'off',
                maxlength: Book::LONG_DESCRIPTION_MAX_LENGTH
              },
              hint: 'Lengri lýsing sem birtist neðan við stuttu lýsinguna á '\
                    'upplýsingasíðu hverrar bókar í vefútgáfu. Tvöfalt '\
                    'línubil jafngildir málsgreinabili.'
    end

    f.inputs 'Mynd af forsíðu' do
      if resource.cover_image.attached?
        f.img src: resource.cover_image_variant_url(266), class: 'cover-image'
      end
      f.input(
        :cover_image_file,
        as: :file,
        input_html: {
          accept: Book::PERMITTED_IMAGE_FORMATS.join(', ')
        },
        hint: 'Tekið er við myndum á sniðunum JPEG, PNG, WebP, '\
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
        input_html: {
          inputmode: 'numeric',
          pattern: '[0-9]*',
          maxlength: 13,
          autocomplete: 'off',
          class: 'barcode'
        }
      )
      bb.input(
        :language,
        include_blank: false,
        collection: BookBindingType::AVAILABLE_LANGUAGES.map do |l|
          ["#{l[0]} - #{I18n.t("languages.#{l[0]}")}", l[0]]
        end,
        input_html: { autocomplete: 'off', class: 'language' }
      )
      bb.input(
        :page_count,
        input_html: { autocomplete: 'off', min: 0, class: 'page-count' }
      )
      bb.input(
        :minutes,
        input_html: { autocomplete: 'off', min: 0, class: 'minutes' }
      )
      bb.input(
        :url,
        input_html: { autocomplete: 'off', class: 'url' }
      )
      bb.input(
        :availability,
        collection: BookBindingType::AVAILABILITIES.map do |s|
          [
            I18n.t(
              "activerecord.attributes.book_binding_type.availabilities.#{s}"
            ),
            s
          ]
        end,
        include_blank: false
      )
      bb.input(
        :publication_date,
        as: :datepicker,
        class: 'publication-date',
        hint: 'Ef bók er skráð sem væntanleg er hún sjálfkrafa skráð sem '\
              'fáanleg á útgáfudegi.'
      )
    end

    f.has_many(
      :book_categories, heading: 'Flokkar (hámark 3)', allow_destroy: true
    ) do |bc|
      bc.input(
        :category,
        collection: grouped_options_for_select(
          Category.grouped_options, bc.object.category_id
        ),
        selected: 3,
        member_label: :name_with_group
      )
      bc.input :for_print
      bc.input :for_web
    end

    if Edition.active.count.positive?
      f.inputs do
        f.input(
          :editions,
          as: :check_boxes,
          collection: Edition.active,
          input_html: { autocomplete: 'off' }
        )
      end
    end

    f.inputs 'Nánari upplýsingar' do
      f.input :original_title, hint: 'Upprunalegur titill bókar ef erlend.'
      f.input(
        :country_of_origin,
        as: :country,
        include_blank: true,
        priority_countries: Book::PRIORITY_COUNTRIES_OF_ORIGIN,
        input_html: { autocomplete: 'off' },
        hint: 'Upprunaland bókar.'
      )
    end

    f.actions
  end
end
