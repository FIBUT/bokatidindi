# frozen_string_literal: true

namespace :bt do
  desc 'Attach images of each cover to the books'
  task attach_covers: :environment do
    active_edition_id = Edition.current.first

    books = Book.joins(:editions).where(
      'editions.id': active_edition_id
    ).where.not(source_id: nil)

    books.each do |b|
      next if b.cover_image.attached?

      url = b.original_cover_bucket_url
      if b.attach_cover_image
        puts "✅ #{b.slug}: Image found and attached from #{url}"
      else
        puts "❌ #{b.slug}: Image not found at #{url}"
      end
      GC.start
    end
  end

  desc 'Update the hypenation processing of book titles'
  task update_hypenation: :environment do
    Book.all.each do |b|
      b.set_title_hypenation
      b.save
      puts "#{b.slug} - #{b.title_hypenated} (#{b.title})"
    end
  end

  desc 'Delete closed binding types with no books associated'
  task delete_empty_binding_types: :environment do
    BindingType.where(open: false).each do |b|
      b.destroy if b.book_count.zero?
    end
  end

  desc 'Rename categories to their display name'
  task rename_categories: :environment do
    category_mappings = [
      { id: 3, name: 'Íslensk skáldverk', g: 1 },
      { id: 4, name: 'Þýdd skáldverk', g: 1 },
      { id: 5, name: 'Ljóð og leikrit', g: 1 },
      { id: 6, name: 'Listir og ljósmyndir', g: 2 },
      { id: 7, name: 'Fræðibækur', g: 2 },
      { id: 8, name: 'Saga, ættfræði og héraðslýsingar', g: 2 },
      { id: 9, name: 'Ævisögur', g: 2 },
      { id: 11, name: 'Matur', g: 2 },
      { id: 14, name: 'Hannyrðir, íþróttir og útivist', g: 2 },
      { id: 20, name: 'Myndskreyttar 0-6 ára', g: 0 },
      { id: 21, name: 'Skáldverk', g: 0 },
      { id: 22, name: 'Fræðibækur og handbækur', g: 0 },
      { id: 23, name: 'Ungmennabækur', g: 0 }
    ].freeze

    category_mappings.each do |m|
      category = Category.find_by(source_id: m[:id])
      category[:name]  = m[:name]
      category[:group] = m[:g]
      category.save
    end
  end

  desc 'Automatically gender Icelandic authors based on son/dóttir'
  task autogender_authors: :environment do
    count = 0
    Author.where(is_icelandic: true, gender: nil).each do |a|
      a[:gender] = :male if a[:lastname].end_with?('son')
      a[:gender] = :female if a[:lastname].end_with?('dóttir')
      a[:gender] = :non_binary if a[:lastname].end_with?('bur')
      count += 1 if a.save
    end
    puts "Gender assumed for #{count} authors."
  end

  desc 'Remove zero-page counts'
  task clean_zero_pages: :environment do
    count = 0
    Book.where(page_count: 0).each do |b|
      count += 1 if b.update(page_count: nil)
    end
    puts "#{count} zero-page counts replaced with nil."
  end

  desc 'Assign a book url to the appropriate book binding type url'
  task assign_book_binding_type_url: :environment do
    bound_book_slugs = ['innbundin', 'sveigjanleg-kapa', 'kilja-vasabrot',
                        'gormabok', 'hardspjaldabok', 'endurutgafa']
    audio_book_slugs = ['hljodbok-sami-utg', 'hljodbok-fra-hljodbok-is',
                        'hljodbok-fra-storytel']

    Book.all.each do |book|
      total_skus = BookBindingType.where(book_id: book.id)

      if total_skus.empty?
        puts "#{book.id} - #{book.slug}: Er ekki með nein útgáfuform skráð."
        next
      end

      bound_skus = BookBindingType.joins(
        :binding_type
      ).where(book_id: book.id, binding_type: { slug: bound_book_slugs })

      if bound_skus.empty?
        if book.uri_to_buy
          ebook_skus = BookBindingType.joins(
            :binding_type
          ).where(book_id: book.id, binding_type: { slug: 'rafbok' })
          if ebook_skus.count.zero?
            puts "#{book.id} - #{book.slug}"\
                 ': Þarf að skoða m.t.t. áþreifanlegra útgáfuforma'
          else
            ebook_skus.first.update(url: book.uri_to_buy)
          end
        end
      else
        bound_skus.first.update(url: book.uri_to_buy) if book.uri_to_buy
        bound_skus.first.update(page_count: book.page_count) if book.page_count
      end

      audio_skus = BookBindingType.joins(
        :binding_type
      ).where(book_id: book.id, binding_type: { slug: audio_book_slugs })

      if audio_skus.empty?
        if book.uri_to_audiobook
          puts "#{book.id} - #{book.slug}: Þarf að skoða m.t.t. hljóðbóka"
        end
      else
        if book.uri_to_audiobook
          audio_skus.first.update(url: book.uri_to_audiobook)
        end
        audio_skus.first.update(minutes: book.minutes) if book.minutes
      end
    end
  end
end
