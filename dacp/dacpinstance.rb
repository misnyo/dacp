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
                #puts @instance
                return
            end
        end
        puts "instance error!"
    end

    def public_dns_name()
        return @instance.public_dns_name
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

    def wait_for_start()
        begin
            @ec2.wait_until(:instance_running, instance_ids:[@instance.instance_id])
            puts "Started instance #{@name}"
        rescue Aws::Waiters::Errors::WaiterFailed => error
            puts "Start failed (#{error.message}) for #{@name}"
        end
    end

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

    def wait_for_stop()
        begin
            @ec2.wait_until(:instance_running, instance_ids:[@instance.instance_id])
            puts "Stopped instance #{@name}"
        rescue Aws::Waiters::Errors::WaiterFailed => error
            puts "Stop failed (#{error.message}) for #{@name}"
        end
    end

    def copy_file(file)
        Net::SCP.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |scp|
            scp.upload(file, '.')
        end
    end

    def install_puppet()
        Net::SSH.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |ssh|
            res = ssh.exec!("sudo apt-get update && sudo apt-get install -y puppet")
            puts res
        end
    end

    def apply_puppet(file)
        self.copy_file(file)
        Net::SSH.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |ssh|
            res = ssh.exec!("sudo puppet apply ~/#{Pathname(file).basename}")
            puts res
        end
    end

    def run_command(command)
        Net::SSH.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |ssh|
            res = ssh.exec!(command)
            puts res
        end
    end

end
