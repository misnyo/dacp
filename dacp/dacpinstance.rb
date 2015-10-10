require 'pp'
require 'net/scp'

class DacpInstance
    def initialize(ec2, options, name)
        @options = options
        @ec2 = ec2
        resp = @ec2.describe_instances({filters:
            [
                {
                    name: "tag:Name",
                    values: [name]
                },
                {
                    name: "instance-state-name",
                    values: ["running"]
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

    def public_dns_name()
        return @instance.public_dns_name
    end

    def copy_file(file)
        Net::SCP.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |scp|
            scp.upload(file, '.')
        end
    end

    def apply_puppet(file)
        self.copy_file(file)
        Net::SSH.start(self.public_dns_name, @options[:login_name], {:keys => @options[:key_location], :port => @options[:ssh_port]}) do |ssh|
            res = ssh.exec!("sudo apt-get update && sudo apt-get install -y puppet")
            puts res
            res = ssh.exec!("sudo puppet apply ~/#{Pathname(file).basename}")
            puts res
        end
    end
end
