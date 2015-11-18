require 'pp'
require 'net/scp'

##
#Represents an AWS instance
class DacpInstance

    ##
    #Queries instance data from AWS
    def initialize(ec2, options, name)
        @options = options
        @ec2 = ec2
        @name = name
        resp = @ec2.describe_instances({filters:
            [
                {
                    name: "tag:Name",
                    values: [name]
                }
            ]})
        if resp.reservations.length == 1
            if resp.reservations[0].instances.length == 1
                @instance = resp.reservations[0].instances[0]
                return
            end
        end
        puts "instance error!"
    end

    ##
    #Private dns name
    def private_dns_name()
        return @instance.private_dns_name
    end

    ##
    #Public dns name
    def public_dns_name()
        return @instance.public_dns_name
    end

    ##
    #Instance id
    def instance_id()
        return @instance.instance_id
    end

    ##
    #Start instance
    def start()
        puts "Starting instance #{@name} ..."
        begin
            @ec2.start_instances({instance_ids: [@instance.instance_id]})
        rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => error
            puts "#{error.message}"
            return
        end
        self.wait_for_start()
    end

    ##
    #Wait until instance_running
    def wait_for_start()
        begin
            @ec2.wait_until(:instance_running, instance_ids:[@instance.instance_id])
            puts "Started instance #{@name}"
        rescue Aws::Waiters::Errors::WaiterFailed => error
            puts "Start failed (#{error.message}) for #{@name}"
        end
    end

    ##
    #Stop instance
    def stop()
        puts "Stopping instance #{@name} ..."
        begin
            @ec2.stop_instances({instance_ids: [@instance.instance_id]})
        rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => error
            puts "#{error.message}"
            return
        end
        self.wait_for_stop()
    end

    ##
    #Wait until instance_running
    def wait_for_stop()
        begin
            @ec2.wait_until(:instance_running, instance_ids:[@instance.instance_id])
            puts "Stopped instance #{@name}"
        rescue Aws::Waiters::Errors::WaiterFailed => error
            puts "Stop failed (#{error.message}) for #{@name}"
        end
    end

    ##
    #Scp given file to instance home
    def copy_file(file)
        success = false
        cnt = 0
        while not success and cnt < 10 do
            begin
                Net::SCP.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port], :timeout => 30}) do |scp|
                    res = scp.upload(file, '.')
                    success = true
                end
            rescue Errno::ECONNREFUSED
                cnt += 1
                puts "Retrying scp #{cnt}th time for #{self.public_dns_name}"
                sleep(10)
            end
        end
    end

    ##
    #Install puppet
    def install_puppet()
        self.run_command("sudo apt-get update && sudo apt-get install -y puppet")
    end

    ##
    #Apply local puppet file on server
    def apply_puppet(file)
        self.copy_file(file)
        self.run_command("sudo puppet apply ~/#{Pathname(file).basename}")
    end

    ##
    #Run remote command
    def run_command(command)
        success = false
        cnt = 0
        while not success and cnt < 10 do
            begin
                Net::SSH.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |ssh|
                    res = ssh.exec!(command)
                    success = true
                end
            rescue Errno::ECONNREFUSED
                cnt += 1
                puts "Retrying scp #{cnt}th time for #{self.public_dns_name}"
                sleep(10)
            end
        end
    end

end
