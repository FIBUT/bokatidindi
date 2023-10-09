# frozen_string_literal: true

ActiveAdmin.register Book do
  permit_params :id, :pre_title, :title, :post_title,
                :description, :long_description,
                :blockquote, :blockquote_source,
                :country_of_origin, :original_title,
                :cover_image_file,
                :audio_sample_file,
                :delete_sample_pages,
                :delete_audio_sample,
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
                  blockquotes_attributes: %i[
                    id quote_type location heading quote citation _destroy
                  ],
                  edition_ids: [],
                  sample_pages_files: []
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

      edition_ids        = permitted_params[:book][:edition_ids].to_a
      @resource.editions = Edition.where(
        id: (
          @resource.editions.frozen.ids +
          @resource.editions.inactive.ids +
          edition_ids
        )
      )

      removed_edition_ids = @resource.editions.where.not(
        id: Edition.inactive.ids + Edition.frozen.ids
      ).where.not(id: (edition_ids - [''])).ids

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

      if permitted_params[:book][:audio_sample_file]
        audio_sample_contents = permitted_params[:book][:audio_sample_file].read

        audio_sample_content_type = MimeMagic.by_magic(audio_sample_contents)
                                             .type

        if Book::PERMITTED_AUDIO_FORMATS.include?(audio_sample_content_type)
          audio_sample_file_valid = true
        else
          @resource.errors.add(:audio_sample_file, :invalid)
        end
      end

      if @resource.errors.none? && @resource.save
        @resource.book_editions.where(
          edition_id: removed_edition_ids
        ).destroy_all
        @resource.book_editions.each do |be|
          be.update_book_edition_categories(force: current_admin_user.admin?)
        end

        @resource.sample_pages.attach(
          permitted_params[:book][:sample_pages_files]
        )

        if permitted_params[:book][:cover_image_file]
          @resource.cover_image.attach(
            permitted_params[:book][:cover_image_file]
          )
        end

        if permitted_params[:book][:delete_sample_pages].to_i == 1
          @resource.sample_pages.purge
        end

        if permitted_params[:book][:delete_audio_sample].to_i == 1
          @resource.audio_sample.purge
        end

        if audio_sample_file_valid
          @resource.attach_audio_sample_from_string(audio_sample_contents)
        end

        Category.update_all_counts

        SetImageVariantsJob.set(
          queue: :book_cover_image_variants
        ).perform_later(@resource)

        return redirect_to(
          admin_books_path,
          notice: "Bókin #{@resource.title} hefur verið uppfærð. Athugið að " \
                  'vinnsla á myndum getur tekið allt að 10 mínútur.'
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

      edition_ids          = permitted_params[:book][:edition_ids].to_a
      @resource.editions   = Edition.where(
        id: (@resource.inactive_edition_ids + edition_ids)
      )

      if permitted_params[:book][:audio_sample_file]
        audio_sample_contents = permitted_params[:book][:audio_sample_file].read

        audio_sample_content_type = MimeMagic.by_magic(audio_sample_contents)
                                             .type

        if Book::PERMITTED_AUDIO_FORMATS.include?(audio_sample_content_type)
          audio_sample_file_valid = true
        else
          @resource.errors.add(:audio_sample_file, :invalid)
        end
      end

      authorize! :create, @resource

      @resource.validate

      if permitted_params[:book][:book_categories_attributes].values.count > 3
        @resource.errors.add(:book_categories, :too_many)
      end

      if @resource.errors.none? && @resource.save
        @resource.cover_image.attach(permitted_params[:book][:cover_image_file])

        @resource.sample_pages.attach(
          permitted_params[:book][:sample_pages_files]
        )

        if audio_sample_file_valid
          @resource.attach_audio_sample_from_string(audio_sample_contents)
        end

        SetImageVariantsJob.set(
          queue: :book_cover_image_variants
        ).perform_later(@resource)

        Category.update_all_counts

        return redirect_to(
          new_admin_book_path,
          notice: "Bókin #{@resource.title} hefur verið skráð."
        )
      end

      flash[:warn] = 'Ekki var hægt að skrá bókina.'
      render :new
    end
  end

  scope 'Allar', :all
  scope 'Í núverandi tbl.', :current

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
        row :authors
        row :publisher
        row :categories
        row :description
        row :long_description
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

    f.div class: 'intro-tip' do
      para 'Áður en lengra er haldið er mikilvægt að forskrá höfunda og aðra '\
           'þá sem komu að gerð bókarinnar, séu þeir ekki skráðir í grunninn '\
           'nú þegar til að skráningin sé gild.'

      para 'Þegar það hefur verið gert þarf að sækja þetta eyðublað upp á '\
           'nýtt til að skrá hvern höfund bókarinnar (eða þýðendur, '\
           'myndhöfunda o.s.frv.) og merkja við hlutverk þeirra.'

      para 'Gilt ISBN-númer þarf einnig að vera skráð fyrir hvert útgáfuform '\
           'en ekki er hægt að skrá sama ISBN-númer oftar en einu sinni.'

      a('Leita að og skrá höfunda', class: 'button', href: '/admin/authors')
    end

    tabs do
      tab I18n.t('active_admin.tabs.book.general') do
        publishers = if current_admin_user.publisher?
                       current_admin_user.publishers
                     else
                       Publisher.all
                     end

        if publishers.count > 1
          f.inputs 'Útefandi' do
            f.input :publisher,
                    collection: publishers,
                    include_blank: false,
                    input_html: { autocomplete: 'off' }
          end
        end

        f.inputs 'Titill' do
          li 'Vinsamlegast ekki skrifa bókatitla eða hluta þeirra í hástöfum '\
             'nema um sé að ræða skammstafanir. Að öðru leyti gilda almennar '\
             'ritreglur um hástaf í upphafi setningar og línu, sérnöfnum '\
             'o.s.frv.',
             class: 'tip'

          f.input :pre_title,
                  required: false,
                  input_html: {
                    autocomplete: 'off',
                    maxlength: Book::TITLE_MAX_LENGTH
                  },
                  hint: 'Nafn ritraðar eða bókaflokks, t.d. „Lærdómsrit '\
                        'Bókmenntafélagsins“, „Risasyrpa“, „Útkall“ '\
                        'eða „Goðheimar 2“. Autt ef ekki á við.'
          f.input :title,
                  required: true,
                  input_html: {
                    autocomplete: 'off',
                    maxlength: Book::TITLE_MAX_LENGTH
                  },
                  hint: 'Titill bókar. Hér má nota táknið | til að skipta '\
                        'orðum upp í orðhluta vegna birtingar á minni skjám '\
                        'og fyrir prentvinnslu. Dæmi: „Brekku|kots|ann|áll“.'
          f.input :post_title,
                  required: false,
                  input_html: {
                    autocomplete: 'off',
                    maxlength: Book::TITLE_MAX_LENGTH
                  },
                  hint: 'Autt ef á ekki við.'
        end

        f.has_many :book_authors,
                   heading: 'Höfundar, þýðendur og aðrir þeir sem koma að '\
                            'bókinni',
                   allow_destroy: true do |ba|
          ba.input :author_type,
                   collection: AuthorType.order(rod: :asc),
                   input_html: { autocomplete: 'off' },
                   hint: 'Vinsamlegast hafið samband við skrifstofu FÍBÚT ef '\
                         'hlutverk vantar í fellilista.'
          ba.input :author,
                   collection: Author.order(:name),
                   hint: 'Hvern og einn höfund, þýðanda, myndhöfund o.s.frv. '\
                         'þarf að skrá í sitt hvoru lagi. Ef höfundur finnst '\
                         'ekki í fellilista þarf að skrá hann með því að '\
                         'smella á „höfundar“ hér efst á síðunni og svo '\
                         '„skrá höfund“.'
        end

        f.inputs 'Meginmálstexti' do
          li 'Athugið að skráning alls texta og yfirlestur er á ábyrgð hvers '\
             'og eins útgefanda.',
             class: 'tip'
          li 'Meginmálstexti er ekki ætlaður í lista yfir höfunda, '\
            'ritnefndir eða aðra þá sem koma að framleiðslu hverrar bókar.',
             class: 'tip'
          li 'Aðeins skal skrifa hástafi í upphafi setninga, í skammstöfunum '\
             'og í sérnöfnum.',
             class: 'tip'
          li 'Hvert línubil jafngildir málsgreinabili.',
             class: 'tip'
          li 'Nota má HTML-kóðann <em> og </em> til að afmarka skáletraðan '\
             'texta. Skáletrun birtist bæði í prent- og vefútgáfu.',
             class: 'tip'
          li 'Allur texti í stuttri og áframhaldandi lýsingu skal vera á '\
             'íslensku, þó svo að bókin sé gefin út á erlendu tungumáli.',
             class: 'tip'

          f.input :description,
                  as: :text,
                  required: true,
                  input_html: {
                    rows: 5,
                    autocomplete: 'off',
                    maxlength: Book::DESCRIPTION_MAX_LENGTH
                  },
                  hint: 'Stuttur kynningartexti sem birtist á yfirlitssíðu '\
                        'vefsins og í prentútgáfu Bókatíðinda. '\
                        "Hámark #{Book::DESCRIPTION_MAX_LENGTH} slög með "\
                        'bilum og HTML-táknum.'
          f.input :long_description,
                  as: :text,
                  input_html: {
                    rows: 30,
                    autocomplete: 'off',
                    maxlength: Book::LONG_DESCRIPTION_MAX_LENGTH
                  },
                  hint: 'Lengri lýsing sem birtist neðan við stuttu lýsinguna '\
                        'á ítarsíðu hverrar bókar í vefútgáfu. '\
                        'Langa lýsingin birtist ekki í prentútgáfu. '\
                        'Autt ef ekki á við.'
        end

        f.inputs 'Mynd af forsíðu' do
          if resource.cover_image.attached?
            f.img(
              src: resource.cover_image_url,
              class: 'cover-image'
            )
          end
          f.input(
            :cover_image_file,
            as: :file,
            input_html: {
              accept: Book::PERMITTED_IMAGE_FORMATS.join(', ')
            },
            hint: 'Tekið er við myndum á sniðunum JPEG, PNG, WebP, '\
                  'JPEG 2000 og JPEG XL. Myndir eru unnar sjálfkrafa yfir í '\
                  'viðeigandi snið fyrir vef og prent við skráningu '\
                  'og þurfa að vera að lágmarki 1600 px breiðar.'
          )
        end

        f.has_many(
          :book_binding_types, heading: 'Útgáfuform', allow_destroy: true
        ) do |bb|
          bb.input(
            :binding_type,
            collection: BindingType.order(rod: :asc),
            input_html: { class: 'binding-type' }
          )
          bb.input(
            :barcode,
            input_html: {
              inputmode: 'numeric',
              pattern: '[0-9]*',
              maxlength: 13,
              autocomplete: 'off',
              class: 'barcode'
            },
            hint: 'Strikamerkið þarf að vera gilt ISBN-13 númer, eða '\
                  'ISSN-númer (á GTIN/EAN 13 formi) þegar um er að ræða '\
                  'tímarit.'
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
            input_html: { autocomplete: 'off', class: 'url' },
            hint: 'Vefslóð beint á viðkomandi bók á vef útgefanda eða '\
                  'söluaðila.'
          )
          bb.input(
            :availability,
            collection: BookBindingType::AVAILABILITIES.map do |s|
              [
                I18n.t(
                  'activerecord.attributes.book_binding_type'\
                  ".availabilities.#{s}"
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
              Category.order(rod: :asc).grouped_options, bc.object.category_id
            ),
            selected: 3,
            member_label: :name_with_group
          )
          bc.input :for_print
          bc.input :for_web
        end

        if Edition.form_collection(current_admin_user.admin?).count.positive?
          f.inputs do
            f.input(
              :editions,
              as: :check_boxes,
              collection: Edition.form_collection(current_admin_user.admin?),
              input_html: { autocomplete: 'off' },
              hint: 'Þegar hakað hefur viðeigandi reit birtist bókin í '\
                    'Bókatíðindum í þeim flokkum sem hafa verið valdir.'\
            )
          end
        end
      end

      tab I18n.t('active_admin.tabs.book.quotes_and_reviews') do
        f.has_many(
          :blockquotes, allow_destroy: true
        ) do |bq|
          bq.input(
            :quote_type,
            include_blank: false,
            collection: Blockquote.quote_types.map do |t|
              [
                I18n.t("activerecord.attributes.blockquote.types.#{t.first}"),
                t.first
              ]
            end,
            hint: 'Tilvitnanir fá sjálfkrafa íslenskar gæsalappir en '\
                  'úrdrættir ekki. Einnig er útlitsmunur.'
          )
          bq.input(
            :location,
            include_blank: false,
            collection: Blockquote.locations.map do |l|
              [
                I18n.t(
                  "activerecord.attributes.blockquote.locations.#{l.first}"
                ),
                l.first
              ]
            end
          )
          bq.input(
            :heading,
            input_html: {
              class: 'blockquote_heading'
            }
          )
          bq.input(
            :quote,
            as: :text,
            input_html: {
              class: 'blockquote_quote',
              rows: 14,
              autocomplete: 'off',
              maxlength: Blockquote::QUOTE_MAX_LENGTH
            },
            hint: 'Stutt tilvitnun, t.d. í ritdóm eða ummfjöllun '\
                  'fjölmiðils, sem birtist í vefútgáfu Bókatíðinda. '\
                  'Gæsalöppum er sjálfkrafa bætt við tilvitunina. '\
                  "Hámark #{Blockquote::QUOTE_MAX_LENGTH} slög með bilum."
          )
          bq.input(
            :citation,
            input_html: {
              class: 'blockquote_citation',
              maxlength: Blockquote::CITATION_MAX_LENGTH
            },
            hint: 'Uppruni tilvitnunarinnar, t.d. Jón Viðar Jónsson, '\
                  'Þjóðviljinn, Lestrarklefinn o.s.frv. '\
                  "Hámark #{Blockquote::CITATION_MAX_LENGTH} slög með bilum."
          )
        end
      end

      tab I18n.t('active_admin.tabs.book.samples') do
        f.inputs 'Hljóðbrot' do
          if resource.audio_sample.attached?
            audio src: resource.audio_sample_url, controls: true
          end
          f.input(
            :audio_sample_file,
            as: :file,
            hint: 'Tekið er við hljóðskrám á sniðunum AAC, MP3, og OGG. '\
                  'Hljóðskrárnar eru ekki unnar sjálfkrafa yfir í mismunandi '\
                  'snið.'
          )
          if resource.audio_sample.attached?
            f.input(:delete_audio_sample, as: :boolean)
          end
        end

        f.inputs 'Sýnishorn innan úr bók' do
          li class: 'sample-pages' do
            resource.sample_pages.each_with_index do |_sample_page, i|
              img(
                src: resource.sample_page_variant_url(i, 150, 'jpg'), width: 75
              )
            end
          end
          f.input(
            :sample_pages_files,
            as: :file,
            input_html: {
              accept: Book::PERMITTED_IMAGE_FORMATS.join(', '),
              multiple: true
            },
            hint: 'Sýnishorn af stökum síðum innan úr prentútgáfu bókar. '\
                  'Hægt er að velja fleiri en eina skrá. '\
                  'Sömu reglur um skráasnið gilda og um forsíðumyndir.'
          )
          unless resource.sample_pages.count.zero?
            f.input(:delete_sample_pages, as: :boolean)
          end
        end
      end

      tab I18n.t('active_admin.tabs.book.bibliography') do
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
          input(
            :original_language,
            include_blank: true,
            collection: BookBindingType::AVAILABLE_LANGUAGES.map do |l|
              ["#{l[0]} - #{I18n.t("languages.#{l[0]}")}", l[0]]
            end,
            input_html: { autocomplete: 'off', class: 'language' },
            hint: 'Upprunalegt tungumál bókar.'
          )
        end
      end
    end

    f.actions
  end
end
