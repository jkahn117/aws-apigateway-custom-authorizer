#
# Minimal implementation of policy returned by API Gateway
# Custom Authorizer
#
require 'concurrent/array'
require 'concurrent/hash'

class AuthorizationPolicy
  
  def initialize(principal_id='')
    @principal_id = principal_id
    @api_key = nil
    @statements = Concurrent::Array.new
    @context = Concurrent::Hash.new
  end

  def put_statement(resource, effect='Allow')
    @statements << {
      'Action': 'execute-api:Invoke',
      'Effect': effect,
      'Resource': resource
    }
    self
  end

  def set_context(name, value)
    @context[name] = value
    self
  end

  def set_api_key(api_key)
    @api_key = api_key
    self
  end

  # {
  # 	"principalId": "my-username",
  # 	"policyDocument": {
  # 		"Version": "2012-10-17",
  # 		"Statement": [
  # 			{
  # 				"Action": "execute-api:Invoke",
  # 				"Effect": "Allow",
  # 				"Resource": "arn:aws:execute-api:us-east-1:123456789012:qsxrty/test/GET/mydemoresource"
  # 		]
  # 	},
  # 	"context": {
  # 		"org": "my-org",
  # 		"role": "admin",
  # 		"createdAt": "2019-01-03T12:15:42"
  # 	},
  #   "usageIdentifierKey": "{api-key}"
  # }
  def to_policy
    {
      principalId: @principal_id,
      policyDocument: {
        'Version': '2012-10-17',
        'Statement': @statements
      }
    }. tap do |p|
      p.merge!({ context: @context }) unless @context.empty?
      p.merge!({ usageIdentifierKey: @api_key }) unless @api_key.nil?
    end
  end
end
