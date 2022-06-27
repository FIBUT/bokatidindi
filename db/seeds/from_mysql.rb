# frozen_string_literal: true

# The variables we use for MySQL authentication
mysql_host     = ENV['MYSQL_HOST'] || 'localhost'
mysql_database = ENV['MYSQL_DATABASE'] || 'bokatidindi-source'
mysql_username = ENV['MYSQL_USERNAME'] || 'root'
mysql_password = ENV['MYSQL_PASSWORD'] || 'root'

# The variables we use for getting the database from the legacy system
http_url = 'http://bokatidindi.oddi.is/dataout/bokatidindi.gz'
http_username = Rails.application.credentials.dig(
  :bokatidindi_legacy, :username
)
http_password = Rails.application.credentials.dig(
  :bokatidindi_legacy, :password
)

def binding_barcode_empty?(barcode)
  return false unless barcode == 'ISBN/EAN13 nr' || barcode.empty?

  true
end

def clean_binding_type(binding_type)
  if binding_type.strip == 'Harðspjalda bók 0-2 ára'
    return 'Harðspjaldabók'
  end

  binding_type.strip
end

def italicize(description)
  description.gsub('>>>', '<em>').gsub('<<<', '</em>')
end

def secure_and_validate_uri_string(uri_string)
  return nil if uri_string.to_s.empty?

  uri = URI.parse(uri_string)
  return nil if uri.scheme.nil?

  uri.scheme = 'https'
  uri.to_s
rescue URI::InvalidURIError
  escaped_uri = URI::DEFAULT_PARSER.escape(uri_string)
  return nil if URI.parse(escaped_uri).scheme.nil?

  escaped_uri
end

unless ENV['SKIP_DUMP']
  puts '⬇️  Getting the database dump from bokatidindi.oddi.is'
  gzipped_dump = URI.open(
    http_url, http_basic_authentication: [http_username, http_password]
  )
  uncompressed_dump = ActiveSupport::Gzip.decompress(gzipped_dump.read)
  modified_time = gzipped_dump.meta['last-modified']

  puts "🕓 The remote database dump was created at: #{modified_time}"
end

puts '🔗 Connecting to MySQL/MariaDB server'
client = Mysql2::Client.new(
  host: mysql_host, database: mysql_database,
  username: mysql_username, password: mysql_password,
  flags: Mysql2::Client::MULTI_STATEMENTS
)

unless ENV['SKIP_DUMP']
  puts '✍️  Writing MySQL dump into the MySQL/MariaDB server'
  client.query(uncompressed_dump)
  client.store_result while client.next_result
end

puts '🚢 Migrating the MySQL/MariaDB data to the ActiveRecord/Postgres database'

binding_type_query = "SELECT bindingtype_id as source_id, name, rodun as rod,
 open FROM bindingtype ORDER BY rod ASC, name ASC"

binding_type_result = client.query binding_type_query

binding_type_result.each do |binding_type_row|
  binding_type_name = clean_binding_type(binding_type_row['name'])

  BindingType.create_with(
    name: binding_type_name,
    rod: binding_type_row['rod'],
    open: binding_type_row['open']
  ).find_or_create_by(source_id: binding_type_row['source_id'])
end

book_query = "SELECT `book`.`book_id`,
TRIM(`bookid_bindingtype_eannr`.eannr) AS eannr,
bindingtype.bindingtype_id, bindingtype.name,
`book`.`category_id`,
`category`.`name` AS `category_name`,
`category`.`rodun` AS `category_rodun`,
`pretitle`, `title`, `posttitle`,
`description`, `description_long`,
`nr_of_pages`, `nr_of_minutes`,
`book`.`publisher_id`,
`publisher`.`name` AS `publisher_name`,
`publisher`.`veffang` AS `publisher_url`,
`book`.`Link2Store`, `book`.`Link2Sample`, `book`.`Link2Listen`,
`book`.`part_of_group`,
`book`.`editionid`, `editions`.`edition_title`
FROM `book`
LEFT JOIN `publisher`
ON `book`.`publisher_id` = `publisher`.`publisher_id`
LEFT JOIN `category`
ON `book`.`category_id` = `category`.`category_id`
LEFT JOIN `bookid_bindingtype_eannr`
ON bookid_bindingtype_eannr.book_id = book.book_id
LEFT JOIN bindingtype
ON bindingtype.bindingtype_id = bookid_bindingtype_eannr.bindingtype_id
LEFT JOIN editions
ON book.editionid = editions.editionid
WHERE ( `book`.`editionid` = 'BT2021' OR `book`.`editionid` = 'BT2022' )
AND `book`.`isgroup` = '0'
ORDER BY book_id"

book_result = client.query book_query

book_result.each do |book_row|
  next if book_row['book_id'] == 16_791 # Test record from Oddi

  edition = Edition.find_or_create_by(
    title: book_row['edition_title'],
    original_title_id_string: book_row['editionid']
  )

  publisher = Publisher.create_with(
    source_id: book_row['publisher_id']
  ).find_or_create_by(
    name: book_row['publisher_name'].strip,
    url: book_row['publisher_url']
  )

  category = Category.create_with(
    source_id: book_row['category_id']
  ).find_or_create_by(
    origin_name: book_row['category_name'].strip,
    rod: book_row['category_rodun']
  )

  book_group_query = "SELECT * FROM `book`
  WHERE `book_id` = #{book_row['part_of_group']}"

  book_group_result = client.query book_group_query

  if book_row['part_of_group'].positive? && book_group_result.first
    pre_title = if book_row['pretitle'].strip.empty?
                  book_group_result.first['title'].strip
                end

    description = if book_row['description'].strip.empty?
                    book_group_result.first['description'].strip
                  end

    long_description = if book_row['description_long'].strip.empty?
                         book_group_result.first['description_long'].strip
                       end
  else
    pre_title        = book_row['pretitle'].strip
    description      = book_row['description'].strip
    long_description = book_row['description_long'].strip
  end

  title_noshy         = book_row['title'].gsub('&shy;', '')
  parameterized_title = title_noshy.parameterize(locale: :is).first(64)
  if parameterized_title.end_with?('-')
    parameterized_title = parameterized_title.chop
  end
  slug = "#{parameterized_title}-#{book_row['book_id']}"

  book_upsert = Book.upsert(
    {
      source_id: book_row['book_id'],
      pre_title: pre_title.strip,
      title: book_row['title'].strip,
      post_title: book_row['posttitle'].strip,
      description: italicize(description).gsub(/&#[0-9]+;/, ''),
      long_description: italicize(long_description).gsub(/&#[0-9]+;/, ''),
      page_count: book_row['nr_of_pages'],
      publisher_id: publisher['id'],
      uri_to_buy: secure_and_validate_uri_string(book_row['Link2Store']),
      uri_to_sample: secure_and_validate_uri_string(book_row['Link2Sample']),
      uri_to_audiobook: secure_and_validate_uri_string(book_row['Link2Listen']),
      title_noshy:,
      slug:
    },
    unique_by: :source_id,
    record_timestamps: true
  )

  book_id = book_upsert.to_a.first['id']

  # This assumes that the books only belong to a single edition.
  # This will be expanded in the future.
  BookEdition.create_with(
    edition:
  ).find_or_create_by(
    book_id:
  )

  # This assumes that the books only belong to a single category.
  # This will be expanded in the future.
  BookCategory.create_with(
    category_id: category.id
  ).find_or_create_by(
    book_id:
  )

  book_binding_type_query = "SELECT bookid_bindingtype_eannr.bindingtype_id,
  TRIM(bookid_bindingtype_eannr.eannr) AS barcode, bindingtype.name
  FROM `bookid_bindingtype_eannr`
  LEFT JOIN bindingtype
  ON bindingtype.bindingtype_id = bookid_bindingtype_eannr.bindingtype_id
  WHERE `bookid_bindingtype_eannr`.`book_id` = #{book_row['book_id']}"

  book_binding_type_result = client.query book_binding_type_query

  book_binding_type_result.each do |book_binding_type_row|
    barcode = if binding_barcode_empty?(book_binding_type_row['barcode'])
                nil
              else
                book_binding_type_row['barcode']
              end

    BookBindingType.create_with(
      barcode:
    ).find_or_create_by(
      book_id:,
      binding_type: BindingType.find_by(
        source_id: book_binding_type_row['bindingtype_id']
      )
    )
  end

  book_author_query = "SELECT isWrittenBy_id, book_id,
  `isWrittenBy`.`author_id`, `isWrittenBy`.authorType_id,
  TRIM(firstname) AS firstname, TRIM(lastname) AS lastname,
  TRIM(`authorType`.name) AS `type_name`, icelandic, `authorType`.rod as `order`
  FROM `isWrittenBy`
  INNER JOIN `author`
  ON `author`.`author_id` = `isWrittenBy`.`author_id`
  INNER JOIN `authorType`
  ON `isWrittenBy`.`authorType_id` = `authorType`.`authorType_id`
  WHERE book_id = #{book_row['book_id']} AND `isWrittenBy`.authorType_id != 11"

  book_author_result = client.query book_author_query

  book_author_result.each do |book_author_row|
    next if book_author_row['author_id'] == 984 # Ýmsir
    next if book_author_row['author_id'] == 11_636 # Test record

    author = Author.create_with(
      firstname: book_author_row['firstname'],
      lastname: book_author_row['lastname']
    ).find_or_create_by(
      source_id: book_author_row['author_id']
    )

    author_type = AuthorType.create_with(
      name: book_author_row['type_name'],
      rod: book_author_row['order']
    ).find_or_create_by(
      source_id: book_author_row['authorType_id']
    )

    BookAuthor.find_or_create_by(
      book_id:,
      author_id: author['id'],
      author_type_id: author_type['id']
    )
  end

  inserted_book = Book.find(book_id)

  print "#{['📗', '📘', '📙'].sample} Book: #{inserted_book.id} - "
  print "#{inserted_book.slug} - #{inserted_book.full_title}\n"
end

e = Edition.last
e.active = true
e.save

puts "#{['😎', '😊', '🎉', '🥂'].sample} #{Book.all.count} books imported!"
