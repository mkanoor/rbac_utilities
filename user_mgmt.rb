# load the gem
require_relative 'setup'
require 'optparse'

def parse_args
  options = {}
  options[:mode] = "add"
  OptionParser.new do |opts|
    opts.banner = "Usage: user_mgmt.rb [options]"
    opts.on("-m", "--mode=value", "Mode (add|remove)") do |value|
      options[:mode] = value
    end
    opts.on("-g", "--group=value", "Group Name") do |value|
      options[:group] = value
    end
    opts.on("-u", "--user=value", "user_name") do |value|
      options[:user] = value
    end
  end.parse!
  options
end


def get_group_uuid(api_instance, group_name)
  match = RBAC::Paginate.call(api_instance, :list_groups, {}).detect { |grp| grp.name == group_name }
  raise "Group Name: #{group_name} not found" unless match
  match.uuid
rescue RBACApiClient::ApiError => e
  puts "Exception when calling GroupApi->list_groups: #{e}"
  raise
end

def remove_user(api_instance, uuid, user)
  puts "Removing user #{user} from #{uuid}"
  #Remove a principal from a group in the tenant
  api_instance.delete_principal_from_group(uuid, user)
rescue RBACApiClient::ApiError => e
  puts "Exception when calling GroupApi->delete_principal_from_group: #{e}"
end


def add_to_group(api_instance, uuid, user)
  puts "Adding user #{user} to group #{uuid}"
  group_principal_in = RBACApiClient::GroupPrincipalIn.new
  principal1 = RBACApiClient::PrincipalIn.new
  principal1.username = user
  group_principal_in.principals = [principal1]

  begin
    #Add a principal to a group in the tenant
    result = api_instance.add_principal_to_group(uuid, group_principal_in)
    p result
  rescue RBACApiClient::ApiError => e
    puts "Exception when calling GroupApi->add_principal_to_group: #{e}"
  end
end

options = parse_args
api_instance = RBACApiClient::GroupApi.new
set_header(api_instance)
uuid = get_group_uuid(api_instance, options[:group])
if options[:mode] == "add"
  add_to_group(api_instance, uuid, options[:user])
elsif options[:mode] == "remove"
  remove_user(api_instance, uuid, options[:user])
else
  puts "Invalid mode #{options[:mode]}"
end
