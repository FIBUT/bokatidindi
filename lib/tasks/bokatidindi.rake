# frozen_string_literal: true

namespace :bt do
  desc 'Update the hypenation processing of book titles'
  task update_hypenation: :environment do
    Book.all.each do |b|
      b.set_title_hypenation
      b.save
      puts "#{b.slug} - #{b.title_hypenated} (#{b.title})"
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

  desc 'Find and destroy orphaned has_many records'
  task destroy_bastards: :environment do
    BookAuthor.all.each do |ba|
      ba.destroy if ba.book.nil? || ba.author.nil?
    end
    BookCategory.all.each do |bc|
      bc.destroy if bc.book.nil? || bc.category.nil?
    end
    BookBindingType.all.each do |bb|
      bb.destroy if bb.book.nil? || bb.binding_type.nil?
    end
    BookEdition.all.each do |be|
      be.destroy if be.book.nil? || be.edition.nil?
    end
  end

  desc 'Update the full name of every author'
  task set_author_names: :environment do
    Author.all.each do |a|
      a.update(name: "#{a.firstname} #{a.lastname}")
    end
  end

  desc 'Maintain the Icelandic database collation'
  task maintain_collation: :environment do
    ActiveRecord::Base.connection.execute(
      'ALTER TABLE authors ALTER COLUMN order_by_name '\
      'SET DATA TYPE character varying COLLATE "is_IS"'
    )
    ActiveRecord::Base.connection.execute(
      'ALTER TABLE authors ALTER COLUMN name '\
      'SET DATA TYPE character varying COLLATE "is_IS"'
    )
    ActiveRecord::Base.connection.execute(
      'ALTER TABLE authors ALTER COLUMN firstname '\
      'SET DATA TYPE character varying COLLATE "is_IS"'
    )
    ActiveRecord::Base.connection.execute(
      'ALTER TABLE authors ALTER COLUMN lastname '\
      'SET DATA TYPE character varying COLLATE "is_IS"'
    )
  end

  desc 'Mark pending book binding types as available on publication day'
  task label_available_on_publication_date: :environment do
    Edition.current_edition.books.each do |b|
      b.book_binding_types.where(availability: :pending).each do |bbt|
        if bbt.publication_date > DateTime.now
          bbt.availability = :available
          bbt.save
        end
      end
    end
  end

  desc 'Order main book author on top'
  task arrange_main_author_on_top: :environment do
    Book.all.each do |b|
      book_authors_array = []
      b.book_authors.where(author_type_id: 2).each do |ba|
        book_authors_array << {
          book_id: b.id,
          author_id: ba.author_id,
          author_type_id: ba.author_type_id
        }
      end
      b.book_authors.where.not(author_type_id: 2).each do |ba|
        book_authors_array << {
          book_id: b.id,
          author_id: ba.author_id,
          author_type_id: ba.author_type_id
        }
      end
      b.book_authors.delete_all
      book_authors_array.each do |nba|
        BookAuthor.create(
          book_id: b.id,
          author_id: nba[:author_id],
          author_type_id: nba[:author_type_id]
        )
      end
    end
  end

  desc 'Create BookEditionCategory records from BookCategory records'
  task assign_categories_to_book_editions: :environment do
    BookEdition.all.each do |book_edition|
      pp book_edition
      book_edition.reset_book_edition_categories
    end
  end

  task nullify_barcodes: :environment do
    BookBindingType.where(barcode: '').each do |bbt|
      bbt[:barcode] = nil
    end
  end

  task identify_long_descriptions: :environment do
    puts ['Útgefandi', 'Raðnúmer', 'Titill'].to_csv
    Book.current.where('LENGTH(description) > 380').each do |b|
      puts [b.publisher.name, b.id, b.title].to_csv
    end
  end

  desc 'Update book counts per category'
  task update_category_counters: :environment do
    Category.all.each do |c|
      c.update_counts
      c.save
    end
  end

  desc 'Generate the print image variant'
  task attach_print_image_variants: :environment do
    Book.all.each do |b|
      next unless b.cover_image?

      puts "✅ #{b.slug}" if b.attach_print_image_variant
    end
  end

  desc 'Run .sanitize_description on all books'
  task sanitize_book_descriptions: :environment do
    Book.all.each do |b|
      b.sanitize_description
      b.save
    end
  end

  desc 'Remove BookBindingType records for \'republished\' books'
  task remove_republished: :environment do
    BookBindingType.includes(:binding_type)
                   .where(binding_type: { name: 'Endurútgáfa' })
                   .destroy_all
  end

  desc 'Reset book_edition_categories for all books'
  task reset_book_edition_categories: :environment do
    Book.all.each(&:reset_book_edition_categories)
  end

  desc 'Prewarm the database'
  task prewarm_database: :environment do
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.execute("SELECT pg_prewarm('#{t}')")
    end
  end
end
