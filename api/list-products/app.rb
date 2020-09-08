require 'faker'
require 'util'

def handler(event:, context:)
  p event

  books = []
  10.times { books << generate_book }
  respond_with_result(books)
end

def generate_book
  {
    id: 12,
    title: "A book",
    author: "By someone",
    price: 8.99
  }
end