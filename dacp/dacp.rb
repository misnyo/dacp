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
require './dacplb'

CONFIG = YAML.load_file("config/config.yaml") unless defined? CONFIG

##
#Main controller class
class Dacp

    ##
    #List of available CLI commands
    @@available_commands = [
        "list",
        "get_dns",
        "start",
        "stop",
        "init_puppet",
        "show_config",
        "enroll_cluster",
        "enroll_vms",
        "enroll_db",
        "enroll_web",
        "destroy_cluster"
    ]
    @@options = {}

    ##
    #Init configuration for API and CLI
    def self.init(api)
        self.parse(api, ARGV)
        self.init_aws()
    end

    ##
    #Runs the command specified in CLI argument
    def self.run()
        self.init(false)
        self.run_command(@@options[:command])
    end

    ##
    #Connection to AWS EC2 client
    def self.init_aws()
        @@ec2 = Aws::EC2::Client.new(region: @@options[:region])
        @@lbc = Aws::ElasticLoadBalancing::Client.new(region: @@options[:region])
    end

    ##
    #Parse arguments
    def self.parse(api, args)
        options = {}
        OptionParser.new do |opts|
            opts.banner = "Usage: dacp.rb [command] [options]"
            opts.separator ""
            opts.separator "Available commands: " + @@available_commands.join(", ")
            opts.separator ""

            opts.on("-i ID", "--instance=ID", "Instance for the command") do |instance|
                @@options[:instance] = instance
            end

            opts.on("-p PREFIX", "--prefix=PREFIX", "Instance prefix") do |prefix|
                @@options[:instance_prefix] = prefix
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
        @@options[:api] = api
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
        @@options[:instance_prefix] = @@options[:instance_prefix] || CONFIG['HOSTS']['INSTANCE_PREFIX']
        #set mysql options
        @@options[:mysql_pw] = CONFIG['MYSQL']['ROOT_PW'] || SecureRandom.hex
        @@options[:mysql_user] = CONFIG['MYSQL']['USER']
        @@options[:mysql_user_pw] = CONFIG['MYSQL']['USER_PW'] || SecureRandom.hex
        @@options[:mysql_db] = CONFIG['MYSQL']['DB']
        #set drupal options
        @@options[:admin_email] = CONFIG['DRUPAL']['EMAIL']
        @@options[:admin_password] = CONFIG['DRUPAL']['PASSWORD'] || SecureRandom.hex
        @@options[:admin_user] = CONFIG['DRUPAL']['USER']
    end

    ##
    #Runs function "run_" + command, defaulting to run_list
    def self.run_command(command)
        if !command
            command = "list"
        end
        raise "Wrong command, try -h" unless \
            @@available_commands.include? command
        self.send "run_" + command
    end

    ##
    #Get all instances in configured region
    def self.get_list()
        @ret = []
        resp = @@ec2.describe_instances()
        return ["No instances found!"] unless !resp.reservations.empty?
        for r in resp.reservations
            for i in r.instances
                @ret << {
                    instance_id: i.instance_id,
                    name: i.tags.find {|t| t.key == "Name"}.value,
                    state: i.state.name,
                    public_dns_name: i.public_dns_name
                }
            end
        end
        return @ret
    end

    ##
    #List all instances in configured region
    def self.run_list()
        for i in self.get_list()
            if i.instance_of? String
                puts i
            else
                puts "#{i[:instance_id]} - #{i[:name]} - #{i[:state]} - #{i[:public_dns_name]}"
            end
        end
    end

    ##
    #Get public facing dns of load balancer
    def self.get_dns()
        lb = DacpLB.new(@@lbc, @@options, "#{@@options[:instance_prefix]}lb-1")
        lb.dns_name
    end

    ##
    #List public facing dns of load balancer
    def self.run_get_dns()
        puts self.get_dns()
    end

    ##
    #Start instance specified in options
    def self.run_start(instance_id=@@options[:instance])
        instance = DacpInstance.new(@@ec2, @@options, instance_id)
        instance.start()
    end

    ##
    #Stop instance specified in options
    def self.run_stop(instance_id=@@options[:instance])
        instance = DacpInstance.new(@@ec2, @@options, instance_id)
        instance.stop()
    end

    ##
    #Initialize puppet parameter templates
    def self.run_init_puppet()
        template = ERB.new File.new("../puppet/params.erb").read, nil, "%"
        File.open('../puppet/params.pp', 'w') do |f|
            f.write template.result(binding)
        end
    end

    ##
    #Initialize puppet drupal parameter template
    def self.init_puppet_drupal()
        @@options[:mysql_host] = DacpInstance.new(@@ec2, @@options, "#{@@options[:instance_prefix]}db-1").private_dns_name
        template = ERB.new File.new("../puppet/drupalparams.erb").read, nil, "%"
        File.open('../puppet/drupalparams.pp', 'w') do |f|
            f.write template.result(binding)
        end
    end

    ##
    #Enroll whole drupal cluster
    #includes:
    # - run_init_puppet
    # - run_init_vms
    # - run_init_db
    # - run_init_web
    def self.run_enroll_cluster()
	self.run_init_puppet()
        self.run_enroll_vms()
        self.run_enroll_db()
        self.run_enroll_web()
    end

    ##
    #Enroll web instance(s)
    def self.run_enroll_web()
        self.init_puppet_drupal()
        instance_web1 = DacpInstance.new(@@ec2, @@options, "#{@@options[:instance_prefix]}web-1")
        instance_web1.wait_for_start()
        instance_web1 = DacpInstance.new(@@ec2, @@options, "#{@@options[:instance_prefix]}web-1")
        instance_web1.install_puppet()
        instance_web1.copy_file("../puppet/drupalparams.pp")
        instance_web1.copy_file("../puppet/templates/apache-config.erb")
        instance_web1.apply_puppet("../puppet/web.pp")
    end

    ##
    #Enroll database instance(s)
    def self.run_enroll_db()
        instance_db= DacpInstance.new(@@ec2, @@options, "#{@@options[:instance_prefix]}db-1")
        instance_db.wait_for_start()
        instance_db= DacpInstance.new(@@ec2, @@options, "#{@@options[:instance_prefix]}db-1")
        self.run_init_puppet()
        instance_db.install_puppet()
        instance_db.run_command("sudo puppet module install puppetlabs-mysql")
        instance_db.copy_file("../puppet/params.pp")
        instance_db.apply_puppet("../puppet/db.pp")
    end

    ##
    #Create AWS instances for cluster with puppet
    def self.run_enroll_vms()
        system "puppet apply ../puppet/create.pp --templatedir ../puppet/templates/"
    end

    ##
    #Destroy cluster 
    def self.run_destroy_cluster()
        system "puppet apply ../puppet/destroy.pp"
    end

    def self.get_config()
        return @@options
    end

    ##
    #Show configuration
    def self.run_show_config()
        pp self.get_config()
    end
end


Dacp.run()
