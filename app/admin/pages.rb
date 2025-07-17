# frozen_string_literal: true

ActiveAdmin.register Page do
  permit_params :title, :body, :slug

  config.filters = false

  index do
    column :title
    column :body
    column :slug
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :body
      a 'Nánar um Markdown', href: 'https://www.markdownguide.org/basic-syntax/',
                             class: 'about-markdown',
                             target: '_blank'
      f.input :slug, hint: 'Vísar í þá undirsíðu sem textinn birtist í.'
    end
    f.actions
  end
end
