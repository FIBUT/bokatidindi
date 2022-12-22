# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    edition = Edition.current_edition

    panel 'Frestir og dagsetningar' do
      table class: 'edition-dates-table' do
        tr do
          th scope: 'row' do
            'Opnað fyrir skráningar'
          end
          td do
            edition.opening_date.strftime('%d.%m.%Y')
          end
          td class: 'description' do
            'Opnað fyrir skráningar í þennan árgang Bókatíðinda.'
          end
        end
        tr do
          th scope: 'row' do
            'Árgangur birtist á vef'
          end
          td do
            edition.online_date.strftime('%d.%m.%Y')
          end
          td class: 'Description' do
            'Þessi árgangur Bókatíðinda birtist á vefnum.'
          end
        end
        tr do
          th scope: 'row' do
            'Lokað fyrir skráningar'
          end
          td do
            edition.closing_date.strftime('%d.%m.%Y')
          end
          td class: 'description' do
            'Lokað fyrir skráningar fram að frágangi prentútgáfu.'
          end
        end
        tr do
          th scope: 'row' do
            'Gengið frá prentútgáfu'
          end
          td do
            edition.print_date.strftime('%d.%m.%Y')
          end
          td class: 'Description' do
            'Eftir þessa dagsetningu er opnað aftur fyrir skráningar í '\
            'vefútgáfu.'
          end
        end
      end
      para 'Athugið að þessar dagsetningar geta breyst án fyrirvara.'
    end

    panel 'Samtalstölur skráninga' do
      table class: 'edition-stats-table' do
        tr do
          th scope: 'row' do
            'Heildarfjöldi bóka'
          end
          td do
            BookEdition.where(edition_id: edition.id).count
          end
        end
        tr do
          th scope: 'row' do
            'Heildarfjöldi skráninga'
          end
          td do
            BookEditionCategory.includes(
              :book_edition
            ).where(
              book_edition: { edition_id: 2 }
            ).count
          end
        end
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end
end
