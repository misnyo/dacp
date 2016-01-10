require 'pp'
require 'net/scp'

##
#Represents an AWS elb
class DacpLB

    ##
    #Queries load balancer data from AWS
    def initialize(lbc, options, name)
        @options = options
        @lbc = lbc
        @name = name
        begin
            resp = @lbc.describe_load_balancers({
                load_balancer_names: [name]
                })
            if resp.load_balancer_descriptions.length == 1
                @load_balancer = resp.load_balancer_descriptions[0]
                return
            end
        rescue Aws::ElasticLoadBalancing::Errors::LoadBalancerNotFound
            puts "load balancer error!"
        end
    end

    ##
    #Dns name
    def dns_name()
        unless @load_balancer.nil?
            return @load_balancer.dns_name
        else
            return nil
        end
    end
end
