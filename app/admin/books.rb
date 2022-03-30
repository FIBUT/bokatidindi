ActiveAdmin.register Book do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :source_id, :pre_title, :title, :post_title, :slug, :description, :long_description, :page_count, :minutes, :store_url, :sample_url, :audio_url, :publisher_id, :book_author_id, :uri_to_buy, :uri_to_sample, :uri_to_audiobook, :title_noshy
  #
  # or
  #
  # permit_params do
  #   permitted = [:source_id, :pre_title, :title, :post_title, :slug, :description, :long_description, :page_count, :minutes, :store_url, :sample_url, :audio_url, :publisher_id, :book_author_id, :uri_to_buy, :uri_to_sample, :uri_to_audiobook, :title_noshy]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  config.create_another = true

  filter :title_contains
  filter :description_contains
  filter :publisher
  filter :authors
  filter :id_equals
  filter :source_id_equals

  index do
    column :id
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

  form do |f|
    f.semantic_errors

    f.inputs 'Titill' do
      f.input :pre_title,
              required: false,
              hint: 'Yfirfyrirsögn; t.d. nafn seríu; birtist fyrir ofan aðaltitil í mina letri.'
      f.input :title,
              required: true,
              hint: 'Aðaltitill bókarinnar; birtist sem aðalfyrirsögn. Hægt er að nota &amp;shy; til að stilla af línuskiptingar fyrir löng orð.'
      f.input :post_title,
              required: false,
              hint: 'Undirfyrirsögn; biritist fyrir neðan aðaltitil í minna letri.'
    end

    f.inputs 'Lýsing' do
      f.input :description,
              as: :text,
              required: true,
              input_html: { rows: 2 },
              hint: 'Stutt lýsing á bók, sem birtist á yfirlittsíðu og í prentútgáfu Bókatíðinda. Hámark 383 slög.'
      f.input :long_description,
              as: :text,
              input_html: { rows: 5 },
              hint: 'Lengri lýsing sem birtist á upplýsingasíðu hverrar bókar í vefútgáfu. Ef þessi reitur er tómur birtist styttri lýsingin í staðinn.'
    end

    f.inputs 'Mynd af forsíðu bókar' do
      f.input :cover_image,
              as: :file,
              hint: 'Myndin þarf að vera í háum gæðum og á JPEG-, PNG- eða WebP-sniði.'
    end

    f.has_many :book_authors, heading: 'Höfundar', allow_destroy: true do |ba|
      ba.input :author_type,
               include_blank: false,
               input_html: { autocomplete: 'off' }
      ba.input :author, input_html: { autocomplete: 'off' }
    end

    f.has_many :book_categories, heading: 'Flokkar', allow_destroy: true do |bc|
      bc.input :category,
               include_blank: false,
               member_label: :name_with_group,
               input_html: { autocomplete: 'off' }
    end

    f.inputs do
      f.input :source_id,
              input_html: { disabled: true },
              hint: 'Upprunalegt raðnúmer bókar úr eldra kerfi FÍBÚT.'
      f.input :publisher,
              input_html: { autocomplete: 'off' }
    end

    f.actions
  end
end
