# frozen_string_literal: true

ActiveAdmin.register Author do
  config.sort_order = 'order_by_name_asc'

  permit_params :firstname, :lastname, :gender, :is_icelandic

  filter :firstname_contains
  filter :lastname_contains

  index do
    selectable_column
    column :name do |author|
      link_to author.name, edit_admin_author_path(author)
    end
    column :gender do |author|
      unless author.gender.nil?
        I18n.t("activerecord.attributes.author.genders.#{author.gender}")
      end
    end
    column :is_icelandic
    column :book_count, &:book_count
    actions defaults: false do |author|
      if current_admin_user.admin? && author.books.none?
        item 'Eyða', admin_author_path(author), method: 'delete',
                                                class: 'member_link'
      end
      item 'Skoða á vef', author_path(author[:slug]), target: '_blank',
                                                      class: 'member_link'
    end
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

    f.div class: 'intro-tip' do
      para 'Athugið að og einn einstakling úr hópi eða tvíeyki þarf að skrá '\
           'sérstaklega og með fullu nafni.'
      para 'Fornafn og eftirnafn höfundar er skráð í sitt hvorn reitinn.'
      para 'Munið einnig að skrá kyn höfundar svo rétt sé og hvort höfundur '\
           'sé íslenskur eða erlendur.'
    end

    f.inputs 'Nafn' do
      f.input :firstname
      f.input(
        :lastname, hint: 'Ef ætlunin er að skrá fleiri en einn höfund eru '\
                         'þeir skráðir sitt hvoru lagi og með fullu nafni.',
                   required: true
      )
      f.input(
        :is_icelandic,
        label: 'Höfundur er íslenskur'
      )
      f.input :gender, include_blank: false
    end

    f.actions
  end

  before_create do |author|
    author.added_by_id = current_admin_user.id
  end
end
