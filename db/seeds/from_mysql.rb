client = Mysql2::Client.new(
  host: 'localhost', database: 'bokatidindi-source',
  username: 'root', password: 'root'
)

binding_type_query = "SELECT bindingtype_id as source_id, name, rodun as rod, open
FROM bindingtype
ORDER BY rod ASC, name ASC"

binding_type_result = client.query binding_type_query

binding_type_result.each do |binding_type_row|
  BindingType.create(
    source_id: binding_type_row['source_id'],
    name: binding_type_row['name'].strip,
    rod: binding_type_row['rod'],
    open: binding_type_row['open']
  )
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
`publisher`.`veffang` AS `publisher_url`
FROM `book`
LEFT JOIN `publisher`
ON `book`.`publisher_id` = `publisher`.`publisher_id`
LEFT JOIN `category`
ON `book`.`category_id` = `category`.`category_id`
JOIN `bookid_bindingtype_eannr`
ON bookid_bindingtype_eannr.book_id = book.book_id
LEFT JOIN bindingtype
ON bindingtype.bindingtype_id = bookid_bindingtype_eannr.bindingtype_id
WHERE `book`.`editionid` = 'BT2020'
ORDER BY book_id"

book_result = client.query book_query

book_result.each do |book_row|
  publisher = Publisher.find_by source_id: book_row['publisher_id']

  publisher ||= Publisher.create(
    source_id: book_row['publisher_id'],
    name: book_row['publisher_name'].strip,
    url: book_row['publisher_url']
  )

  category = Category.find_by source_id: book_row['category_id']

  category ||= Category.create(
    source_id: book_row['category_id'],
    name: book_row['category_name'].strip,
    rod: book_row['category_rodun']
  )

  if book_row['eannr'] == 'ISBN/EAN13 nr' || book_row['eannr'].empty?
    book = Book.find_by(source_id: book_row['book_id'])
  else
    book = Book.joins(:book_binding_types).find_by(book_binding_types: { barcode: book_row['eannr'] })
  end

  book ||= Book.create(
    source_id: book_row['book_id'],
    pre_title: book_row['pretitle'].strip,
    title: book_row['title'].strip,
    post_title: book_row['posttitle'].strip,
    description: book_row['description'].strip,
    long_description: book_row['description_long'],
    page_count: book_row['nr_of_pages'],
    publisher_id: publisher['id']
  )

  puts "Book: #{book.source_id} to #{book.id} - #{book.title} - #{category.name}" 

  book_category = BookCategory.find_by(book_id: book.id, category_id: category.id)
  book_category ||= BookCategory.create(
    book_id: book.id,
    category_id: category.id
  );

  book_binding_type_query = "SELECT bookid_bindingtype_eannr.bindingtype_id, TRIM(bookid_bindingtype_eannr.eannr) AS barcode, bindingtype.name
  FROM `bookid_bindingtype_eannr`
  LEFT JOIN bindingtype
  ON bindingtype.bindingtype_id = bookid_bindingtype_eannr.bindingtype_id
  WHERE `bookid_bindingtype_eannr`.`book_id` = #{book_row['book_id']}"

  book_binding_type_result = client.query book_binding_type_query

  book_binding_type_result.each do |book_binding_type_row|
    if book_binding_type_row['barcode'] == 'ISBN/EAN13 nr' || book_binding_type_row['barcode'].empty?
      barcode = nil
    else
      barcode = book_binding_type_row['barcode']
    end
    book_binding_type = BookBindingType.find_by(
      barcode: barcode,
      book_id: book.id,
      binding_type: BindingType.find_by(source_id: book_binding_type_row['bindingtype_id'])
    )
    book_binding_type ||= BookBindingType.create(
      barcode: barcode,
      book_id: book.id,
      binding_type: BindingType.find_by(source_id: book_binding_type_row['bindingtype_id'])
    )
  end

  book_author_query = 'SELECT isWrittenBy_id, book_id,
  `isWrittenBy`.`author_id`, `isWrittenBy`.authorType_id,
  TRIM(firstname) AS firstname, TRIM(lastname) AS lastname,
  TRIM(`authorType`.name) AS `type_name`, icelandic, `authorType`.rod as `order`
  FROM `isWrittenBy`
  INNER JOIN `author` ON `author`.`author_id` = `isWrittenBy`.`author_id`
  INNER JOIN `authorType` ON `isWrittenBy`.`authorType_id` = `authorType`.`authorType_id`
  WHERE book_id = ' + book_row['book_id'].to_s

  book_author_result = client.query book_author_query

  book_author_result.each do |book_author_row|
    author      = Author.find_by source_id: book_author_row['author_id']
    author_type = AuthorType.find_by source_id: book_author_row['authorType_id']

    author ||= Author.create(
      source_id: book_author_row['author_id'],
      firstname: book_author_row['firstname'],
      lastname: book_author_row['lastname']
    )

    author_type ||= AuthorType.create(
      source_id: book_author_row['authorType_id'],
      name: book_author_row['type_name'],
      rod: book_author_row['order']
    )

    book_author = BookAuthor.find_by(
      book_id: book['id'],
      author_id: author['id'],
      author_type_id: author_type['id']
    )
    book_author ||= BookAuthor.create(
      source_id: nil,
      book_id: book['id'],
      author_id: author['id'],
      author_type_id: author_type['id']
    )
  end
end
