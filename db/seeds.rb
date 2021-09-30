# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

client = Mysql2::Client.new(
  host: 'localhost', database: 'bokatidindi-source',
  username: 'root', password: 'root'
)

book_query = "SELECT `book`.`book_id`, `pretitle`, `title`, `posttitle`,
`description`, `description_long`, `book`.`publisher_id`,
`book`.`category_id`, `nr_of_pages`, `nr_of_minutes`,
`category`.`name` AS `category_name`,
`category`.`rodun` AS `category_rodun`,
`publisher`.`name` AS `publisher_name`,
`publisher`.`veffang` AS `publisher_url`,
`bookid_bindingtype_eannr`.`bindingtype_id` AS `bindingtype_id`,
`bindingtype`.`name` AS `bindingtype_name`,
`bindingtype`.`rodun` AS `bindingtype_rod`
FROM `book`
LEFT JOIN `publisher`
ON `book`.`publisher_id` = `publisher`.`publisher_id`
LEFT JOIN `category`
ON `book`.`category_id` = `category`.`category_id`
LEFT JOIN  `bookid_bindingtype_eannr`
ON `book`.book_id = `bookid_bindingtype_eannr`.`book_id`
LEFT JOIN `bindingtype`
ON `bookid_bindingtype_eannr`.`bindingtype_id` = `bindingtype`.`bindingtype_id`
WHERE `book`.`editionid` = 'BT2020'"

book_result = client.query book_query

book_result.each do |book_row|
  publisher = Publisher.find_by source_id: book_row['publisher_id']

  publisher ||= Publisher.create(
    source_id: book_row['publisher_id'],
    name: book_row['publisher_name'],
    url: book_row['publisher_url']
  )

  category = Category.find_by source_id: book_row['category_id']

  category ||= Category.create(
    source_id: book_row['category_id'],
    name: book_row['category_name'],
    rod: book_row['category_rodun']
  )

  book = Book.create(
    source_id: book_row['book_id'],
    pre_title: book_row['pretitle'],
    title: book_row['title'],
    post_title: book_row['posttitle'],
    description: book_row['description'],
    long_description: book_row['description_long'],
    page_count: book_row['nr_of_pages'],
    publisher_id: publisher['id'],
    category_id: category['id']
  )

  puts book.slug

  book_author_query = 'SELECT isWrittenBy_id, book_id,
  `isWrittenBy`.`author_id`, `isWrittenBy`.authorType_id, firstname, lastname,
  `authorType`.name AS `type_name`, icelandic, `authorType`.rod as `order`
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

    book_author = BookAuthor.create(
      source_id: book_author_row['isWrittenBy_id'],
      book_id: book['id'],
      author_id: author['id'],
      author_type_id: author_type['id']
    )
  end
end
