require 'json'

def respond_with_result(result)
  respond_with(200, result)
end

def respond_with_error(error, error_code=400)
  msg = error.is_a?(String) ? error : error.message
  respond_with(msg, error_code)
end

#
# Helper function to format Lambda payload response properly
#
def respond_with(statusCode, body)
  {
    isBase64Encoded: false,
    statusCode: statusCode,
    headers: {
      'Content-Type': body.is_a?(String) ? 'text/html' : 'application/json'
    },
    body: body.is_a?(String) ? body : body.to_json
  }
end