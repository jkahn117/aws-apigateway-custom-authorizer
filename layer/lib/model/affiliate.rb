#
# Model representation of an Affiliate record in our database.
#

require 'aws-record'

class Affiliate
  include Aws::Record

  set_table_name ENV['AFFILIATE_TABLE']

  string_attr :OrgId, hash_key: true
  string_attr :Name
  string_attr :ApiKey
  string_attr :ApiKeyId
  string_attr :Plan

  alias_method :org_id, :OrgId
  alias_method :api_key, :ApiKey
  alias_method :plan, :Plan

  class << self
    def find_by(org_id:)
      find('OrgId': org_id.to_s)
    end
  end
end
