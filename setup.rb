# load the gem
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'rbac-api-client', :git => 'https://github.com/RedHatInsights/insights-rbac-api-client-ruby', :branch => 'master'
  gem 'byebug'
end
require 'byebug'
require 'yaml'
require 'base64'
require_relative 'rbac_pagination'
include RBAC::Paginate

def set_header(api)
  if File.exist?('./user.yml')
    user = YAML.load_file('./user.yml')
    headers = { 'x-rh-identity' => Base64.strict_encode64(user.to_json) }
    api.api_client.default_headers = api.api_client.default_headers.merge(headers)
  end
end

# setup authorization
RBACApiClient.configure do |config|
  hash  = YAML.load_file('./rbac_config.yml')
  hash.keys.each do |key|
    config.send("#{key}=".to_sym, hash[key])
  end
end

