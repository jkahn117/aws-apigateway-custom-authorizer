require 'jwt'
require 'json'
require 'aws-sdk-secretsmanager'

require './auth_policy'
require './errors'
require 'model/affiliate'

$secret_key = nil
$secrets_client = nil

#
# Main handler method
#
def handler(event:, context:)
  p "Method ARN: #{event['methodArn']}"

  decoded_token = nil

  begin
    token = event['authorizationToken'].match(/Bearer\s(.+)$/)[1]
    raise Error::DecodeError.new('No token provided.') unless token

    decoded_token = JWT.decode(token, get_jwt_secret, true, { algorithm: 'HS256' })
  ## TODO: add support for more errors that JWT can throw when decoding....
  rescue JWT::DecodeError
    raise Error::DecodeError.new('Could not decode provided token.')
  end

  policy = if decoded_token[0]['admin']
    build_admin_policy(
      principal_id: decoded_token[0]['sub'],
      requested_arn: event['methodArn']
    )
  else
    affiliate = get_affiliate(decoded_token[0]['orgId'])
    build_affiliate_policy(
      affiliate: affiliate,
      principal_id: decoded_token[0]['sub'],
      requested_arn: event['methodArn']
    )
  end
  
  policy.to_policy
end

###
def build_admin_policy(principal_id:, requested_arn:)
  arn_parts = requested_arn.split('/')
  policy = AuthorizationPolicy.new(principal_id=principal_id)
  policy.put_statement("#{arn_parts[0]}/#{arn_parts[1]}/*")

  policy
end

###
def build_affiliate_policy(affiliate:, principal_id:, requested_arn:)
  arn_parts = requested_arn.split('/')

  policy = AuthorizationPolicy.new(principal_id=principal_id)
  policy.set_context('orgId', affiliate.org_id)
  policy.set_context('plan', affiliate.plan)
  ## TODO: could make this logic more complex
  policy.put_statement("#{arn_parts[0]}/#{arn_parts[1]}/GET/products")
  policy.put_statement("#{arn_parts[0]}/#{arn_parts[1]}/GET/products/*")
  # Explicitly block admin actions
  policy.put_statement("#{arn_parts[0]}/#{arn_parts[1]}/*/admin/*", "Deny")
  policy.set_api_key(affiliate.api_key)

  policy
end

###
def get_jwt_secret
  return $secret_key if $secret_key

  if $secrets_client.nil?
    $secrets_client = Aws::SecretsManager::Client.new
  end

  $secret_key = $secrets_client.get_secret_value({
    secret_id: ENV['SECRET_NAME']
  }).secret_string

  $secret_key
end

###
def get_affiliate(org_id)
  return nil unless org_id

  begin
    Affiliate.find_by(org_id: org_id.to_s)
  rescue
    raise Error::NoSuchOrg.new('Could not find matching affiliate plan')
  end
end


