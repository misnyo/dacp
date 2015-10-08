require 'pp'

class DacpInstance
    def initialize(ec2, name)
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
                pp @instance
                return
            end
        end
        puts "instance error!"
    end

    def public_dns_name()
        return @instance.public_dns_name
    end
end
