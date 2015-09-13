require 'rubygems'
require 'bundler/setup'
require 'aws-sdk'
require 'yaml'
require 'optparse'
require 'pp'

CONFIG = YAML.load_file("config/config.yaml") unless defined? CONFIG

class Opice

    @@available_commands = ["list", "start", "stop"]
    @@options = {}

    def self.run()
        self.parse(ARGV)
        self.init_aws()
        self.run_command(@@options[:command])
    end

    def self.init_aws()
        @@ec2 = Aws::EC2::Client.new(region: CONFIG['awsconfig']['AWS_REGION'], 
                   credentials: Aws::Credentials.new(
                       CONFIG['awsconfig']['AWS_ACCESS_KEY_ID'], 
                       CONFIG['awsconfig']['AWS_SECRET_ACCESS_KEY']))
    end

    def self.parse(args)
        options = {}
        OptionParser.new do |opts|
            opts.banner = "Usage: opice.rb [command] [options]"
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
        for r in resp.reservations
            for i in r.instances
                puts "#{i.instance_id} - #{i.state.name}"
            end
        end
    end

    def self.run_start()
        raise "Please specify an instance for the command!" unless \
            @@options[:instance] or CONFIG['awsconfig']['default_instance']
        if !@@options[:instance]
            @@options[:instance] = !CONFIG['awsconfig']['default_instance']
        end
        puts "Starting instance #{@@options[:instance]} ..."
        @@ec2.start_instances({instance_ids: [@@options[:instance]]})
    end

    def self.run_stop()
        raise "Please specify an instance for the command!" unless \
            @@options[:instance] or CONFIG['awsconfig']['default_instance']
        if !@@options[:instance]
            @@options[:instance] = CONFIG['awsconfig']['default_instance']
        end
        puts "Stopping instance #{@@options[:instance]} ..."
        @@ec2.stop_instances({instance_ids: [@@options[:instance]]})
    end
end


Opice.run()
