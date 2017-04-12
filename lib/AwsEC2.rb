class AwsEC2

    require 'aws-sdk'

    attr_accessor :aws_profile, :aws_region

    def initialize(aws_profile: nil, aws_region: nil)
        @aws_profile = aws_profile
        @aws_region = aws_region
    end

# Public methods here

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
