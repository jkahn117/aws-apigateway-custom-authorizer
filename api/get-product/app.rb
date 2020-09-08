require 'util'

def handler(event:, context:)
  p event

  respond_with_result({
    id: event.dig('pathParameters', 'id'),
    title: "Book",
    author: "Author",
    price: 2.99
  })
end