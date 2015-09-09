require 'rubygems'
require 'bundler/setup'
require 'aws-sdk'
require 'yaml'
require 'optparse'

CONFIG = YAML.load_file("config/config.yaml") unless defined? CONFIG
available_commands = ["list", "start", "stop"]

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: opice.rb command [options]"
  opts.separator ""
  opts.separator "Available commands: " + available_commands.join(", ")
  opts.separator ""

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!
command = ARGV.pop
raise "Need to specify a command" unless command
raise "Wrong command, try -h" unless available_commands.include? command

ec2 = Aws::EC2::Client.new(region: CONFIG['awsconfig']['AWS_REGION'], 
           credentials: Aws::Credentials.new(
               CONFIG['awsconfig']['AWS_ACCESS_KEY_ID'], 
               CONFIG['awsconfig']['AWS_SECRET_ACCESS_KEY']))

resp = ec2.describe_instances()
for i in resp.reservations[0].instances
    puts "#{i.instance_id} - #{i.state.name}"
end
