class AwsEC2

    require 'aws-sdk'

    attr_accessor :aws_profile, :aws_region

    def initialize(aws_profile: nil, aws_region: nil)
        @aws_profile = aws_profile
        @aws_region = aws_region
    end

    def get_orphaned_ebs_volumes
        res = []
        ec2_client.describe_volumes({
            filters: [
                {
                    name: "status",
                    values: ["available"]
                }
            ]
        }).volumes.map do |v|
            res << v.volume_id
        end

        res

    end

    def get_non_elb_instances
        all_instances = []
        res = []
        elbs = {}

        ec2_client.describe_instances.reservations.map do |r|
            r.instances.map do |i|
                all_instances << i.instance_id
            end
        end

        elb_client.describe_load_balancers.load_balancer_descriptions.map do |elb|
            elbs[elb.load_balancer_name] = elb.instances.map do |i|
                i.instance_id
            end
        end

        all_instances - elbs.values.flatten

    end

    private
    def load_profile
        profile = Aws::SharedCredentials.new(
            profile_name: @aws_profile,
            region: @aws_region
        )
    end

    def ec2_client
        profile = load_profile
        ec2 = Aws::EC2::Client.new(
            region: @aws_region,
            credentials: profile.credentials
        )
    end

    def elb_client
        profile = load_profile
        elb = Aws::ElasticLoadBalancing::Client.new(
            region: @aws_region,
            credentials: profile.credentials
        )
    end

end
