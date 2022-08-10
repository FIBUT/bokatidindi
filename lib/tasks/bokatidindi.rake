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
    Edition.current.first.books.each do |b|
      b.book_binding_types.where(availability: :pending).each do |bbt|
        if bbt.publication_date > DateTime.now
          bbt.availability = :available
          bbt.save
        end
      end
    end
  end
end
