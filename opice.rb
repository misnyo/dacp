require 'rubygems'
require 'bundler/setup'
require 'aws-sdk'
require 'yaml'

CONFIG = YAML.load_file("config/config.yaml") unless defined? CONFIG

ec2 = Aws::EC2::Client.new(region: CONFIG['awsconfig']['AWS_REGION'], 
           credentials: Aws::Credentials.new(
               CONFIG['awsconfig']['AWS_ACCESS_KEY_ID'], 
               CONFIG['awsconfig']['AWS_SECRET_ACCESS_KEY']))

resp = ec2.describe_instances()
for i in resp.reservations[0].instances
    puts "#{i.instance_id} - #{i.state.name}"
end
