require 'pp'

##
#Represents an AWS security group
class DacpSg

    ##
    #Queries security group data from AWS
    def initialize(ec2, options, name)
        @options = options
        @ec2 = ec2
        @name = name
        resp = @ec2.describe_security_groups({filters:
            [
                {
                    name: "group-name",
                    values: [name]
                }
            ]})
        if resp.security_groups.length == 1
            @security_group = resp.security_groups[0]
            return
        end
        puts "instance error!"
    end

    ##
    #Security group id
    def group_id()
        return @security_group.group_id
    end
end
