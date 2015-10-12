#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'aws-sdk'
require 'yaml'
require 'optparse'
require 'pp'
require 'erb'
require 'securerandom'
require './dacpinstance'

CONFIG = YAML.load_file("config/config.yaml") unless defined? CONFIG

class Dacp

    @@available_commands = [
        "list",
        "start",
        "stop",
        "init_puppet",
        "show_config",
        "enroll_cluster"
    ]
    @@options = {}

    def self.run()
        self.parse(ARGV)
        self.init_aws()
        self.run_command(@@options[:command])
    end

    def self.init_aws()
        @@ec2 = Aws::EC2::Client.new(region: @@options[:region])
    end

    def self.parse(args)
        options = {}
        OptionParser.new do |opts|
            opts.banner = "Usage: dacp.rb [command] [options]"
            opts.separator ""
            opts.separator "Available commands: " + @@available_commands.join(", ")
            opts.separator ""

            opts.on("-i ID", "--instance=ID", "Instance for the command") do |instance|
                @@options[:instance] = instance
            end

            opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
                @@options[:verbose] = v
            end
            opts.on_tail("-h", "--help", "Show this message") do
                puts opts
                exit
            end
        end.parse!
        command = ARGV.shift
        if command
            raise "Wrong command, try -h" unless \
                @@available_commands.include? command
        end
        @@options[:command] = command
        @@options[:security_group] = CONFIG['awsconfig']['SECURITY_GROUP']
        @@options[:key_name] = CONFIG['awsconfig']['KEY_NAME']
        @@options[:key_location] = CONFIG['awsconfig']['KEY_LOCATION']
        @@options[:image_id] = CONFIG['awsconfig']['IMAGE_ID']
        @@options[:region] = CONFIG['awsconfig']['AWS_REGION']
        @@options[:ssh_port] = CONFIG['awsconfig']['SSH_PORT']
        @@options[:login_name] = CONFIG['awsconfig']['LOGIN_NAME']
        @@options[:mysql_pw] = CONFIG['awsconfig']['MYSQL_PW'] || SecureRandom.hex
    end

    def self.run_command(command)
        if !command
            command = "list"
        end
        raise "Wrong command, try -h" unless \
            @@available_commands.include? command
        self.send "run_" + command
    end

    def self.run_list()
        resp = @@ec2.describe_instances()
        puts "No instances found!" unless !resp.reservations.empty?
        for r in resp.reservations
            for i in r.instances
                puts "#{i.instance_id} - #{i.tags.find {|t| t.key == "Name"}.value} - #{i.state.name} - #{i.public_dns_name}"
            end
        end
    end

    def self.run_start()
        raise "Please specify an instance for the command!" unless \
            @@options[:instance] or CONFIG['awsconfig']['default_instance']
        puts "Starting instance #{@@options[:instance]} ..."
        begin
            @@ec2.start_instances({instance_ids: [@@options[:instance]]})
        rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => error
            puts "#{error.message}"
            return
        end
        begin
            @@ec2.wait_until(:instance_running, instance_ids:[@@options[:instance]])
            puts "Started instance #{@@options[:instance]}"
        rescue Aws::Waiters::Errors::WaiterFailed => error
            puts "Start failed (#{error.message}) for #{@@options[:instance]}"
        end
    end

    def self.run_stop()
        raise "Please specify an instance for the command!" unless \
            @@options[:instance] or CONFIG['awsconfig']['default_instance']
        puts "Stopping instance #{@@options[:instance]} ..."
        begin
            @@ec2.stop_instances({instance_ids: [@@options[:instance]]})
        rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => error
            puts "#{error.message}"
            return
        end
        begin
            @@ec2.wait_until(:instance_stopped, instance_ids:[@@options[:instance]])
            puts "Stopped instance #{@@options[:instance]}"
        rescue Aws::Waiters::Errors::WaiterFailed => error
            puts "Stop failed (#{error.message}) for #{@@options[:instance]}"
        end
    end

    def self.run_init_puppet()
        keyname = @@options[:key_name]
        image_id = @@options[:image_id]
        region = @@options[:region]
        template = ERB.new File.new("../puppet/params.erb").read, nil, "%"
        File.open('../puppet/params.pp', 'w') do |f|
            f.write template.result(binding)
        end
    end

    def self.run_enroll_cluster()
        self.enroll_web()
    end

    def self.enroll_web()
        instance_web1 = DacpInstance.new(@@ec2, @@options, "web-1")
        #puts "#{instance_web1.public_dns_name} - #{@@login_name} - #{@@options[:key_location]} - #{@@options[:ssh_port]}"
        instance_web1.apply_puppet("../puppet/web.pp")
    end

    def self.run_show_config()
        pp @@options
    end
end


Dacp.run()
