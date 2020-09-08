require 'json'
require 'securerandom'
require 'aws-sdk-ssm'
require 'aws-sdk-apigateway'
require 'util'
require 'model/affiliate'

$apigw_client = nil
$ssm_client = nil


#
# Expected payload:
# {
#   "name": "<affiliate name>",
#   "plan": "<SILVER|GOLD>"
# }
#
def handler(event:, context:)
  p event

  params = JSON.parse(event.dig('body'))

  if $apigw_client.nil?
    $apigw_client = Aws::APIGateway::Client.new
  end
  
  unless params['name'] && params['plan']
    raise 'Missing required parameters'
  end

  org_id = SecureRandom.uuid

  affiliate = create_affiliate(org_id: org_id, name: params['name'], plan: params['plan'])
  api_key = create_api_key(org_id: org_id, affiliate_name: params['name'])

  $apigw_client.create_usage_plan_key({
    usage_plan_id: get_usage_plan(plan: params['plan']),
    key_id: api_key[:id],
    key_type: 'API_KEY'
  })

  affiliate.ApiKeyId = api_key[:id]
  affiliate.ApiKey = api_key[:key]
  affiliate.save!

  respond_with_result({
    message: "Affiliate #{affiliate.Name} created! An API Key has been provisioned.",
    name: affiliate.Name,
    plan: affiliate.Plan,
    orgId: affiliate.OrgId
  })
end

###
def create_affiliate(org_id:, name:, plan:)
  affiliate = Affiliate.new(OrgId: org_id, Name: name, Plan: plan)
  affiliate.save!
  affiliate
end

###
def get_usage_plan(plan:)
  if $ssm_client.nil?
    $ssm_client = Aws::SSM::Client.new
  end

  plan_identifier = plan === 'GOLD' ? ENV['GOLD_USAGE_PLAN_PARAM'] : ENV['SILVER_USAGE_PLAN_PARAM']

  $ssm_client.get_parameter({
    name: plan_identifier
  }).parameter.value
end

###
def create_api_key(org_id:, affiliate_name:)
  key = $apigw_client.create_api_key({
    name: "#{affiliate_name}-#{org_id}",
    description: 'Sample API Key',
    enabled: true
  })

  { id: key.id, key: key.value }
end