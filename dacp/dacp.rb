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

##
#Main controller class
class Dacp

    @@available_commands = [
        "list",
        "start",
        "stop",
        "init_puppet",
        "show_config",
        "enroll_cluster",
        "enroll_vms",
        "enroll_db",
        "enroll_web"
    ]
    @@options = {}

    ##
    #Runs the command specified in CLI argument
    def self.run()
        self.parse(ARGV)
        self.init_aws()
        self.run_command(@@options[:command])
    end

    ##
    #Connection to AWS EC2 client
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
	#set awsconfig options
        @@options[:security_group] = CONFIG['AWSCONFIG']['SECURITY_GROUP']
        @@options[:key_name] = CONFIG['AWSCONFIG']['KEY_NAME']
        @@options[:key_location] = CONFIG['AWSCONFIG']['KEY_LOCATION']
        @@options[:image_id] = CONFIG['AWSCONFIG']['IMAGE_ID']
        @@options[:region] = CONFIG['AWSCONFIG']['AWS_REGION']
	#set host options
        @@options[:ssh_port] = CONFIG['HOSTS']['SSH_PORT']
        @@options[:login_name] = CONFIG['HOSTS']['LOGIN_NAME']
        #set mysql options
        @@options[:mysql_pw] = CONFIG['MYSQL']['ROOT_PW'] || SecureRandom.hex
        @@options[:mysql_user] = CONFIG['MYSQL']['USER']
        @@options[:mysql_user_pw] = CONFIG['MYSQL']['USER_PW'] || SecureRandom.hex
        @@options[:mysql_db] = CONFIG['MYSQL']['DB']
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
        instance = DacpInstance.new(@@ec2, @@options, @@options[:instance])
        instance.start()
    end

    def self.run_stop()
        instance = DacpInstance.new(@@ec2, @@options, @@options[:instance])
        instance.stop()
    end

    def self.run_init_puppet()
        @@options[:mysql_host] = DacpInstance.new(@@ec2, @@options, "db-1").public_dns_name
        template = ERB.new File.new("../puppet/params.erb").read, nil, "%"
        File.open('../puppet/params.pp', 'w') do |f|
            f.write template.result(binding)
        end
    end

    def self.init_puppet_drupal()
        @@options[:mysql_host] = DacpInstance.new(@@ec2, @@options, "db-1").public_dns_name
        template = ERB.new File.new("../puppet/drupalparams.erb").read, nil, "%"
        File.open('../puppet/drupalparams.pp', 'w') do |f|
            f.write template.result(binding)
        end
    end

    def self.run_enroll_cluster()
	self.run_init_puppet()
        self.run_enroll_vms()
        self.run_enroll_db()
        self.run_enroll_web()
    end

    def self.run_enroll_web()
        self.init_puppet_drupal()
        instance_web1 = DacpInstance.new(@@ec2, @@options, "web-1")
        instance_web1.wait_for_start()
        instance_web1.install_puppet()
        instance_web1.copy_file("../puppet/drupalparams.pp")
        instance_web1.apply_puppet("../puppet/web.pp")
    end

    def self.run_enroll_db()
        instance_db= DacpInstance.new(@@ec2, @@options, "db-1")
        instance_db.wait_for_start()
        self.run_init_puppet()
        instance_db.install_puppet()
        instance_db.run_command("sudo puppet module install puppetlabs-mysql")
        instance_db.copy_file("../puppet/params.pp")
        instance_db.apply_puppet("../puppet/db.pp")
    end

    def self.run_enroll_vms()
        system "puppet apply ../puppet/create.pp --templatedir ../puppet/templates/"
    end

    def self.run_show_config()
        pp @@options
    end
end


Dacp.run()
