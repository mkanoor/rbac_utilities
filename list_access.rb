require_relative 'setup'

def model_acl(data, table_name, verb)
  regexp = Regexp.new(":(#{table_name}|\\*):(#{verb}|\\*)")
  data.select { |item| regexp.match(item.permission) }
end

api_instance = RBACApiClient::AccessApi.new
application = 'catalog'

opts = {
  limit: 10, # Integer | Parameter for selecting the amount of data in a page.
  offset: 0 # Integer | Parameter for selecting the page of data.
}
begin
  #Get the permitted access for a principal in the tenant
  result = api_instance.send(:get_principal_access, *[application, opts])
  puts result
  puts model_acl(result.data, "portfolios", "read")
rescue RBACApiClient::ApiError => e
  puts "Exception when calling AccessApi->get_principal_access: #{e}"
end
