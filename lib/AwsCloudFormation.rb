class AwsCloudFormation
    require 'aws-sdk'
    require 'time'

    attr_accessor :aws_profile, :aws_region

    def initialize(aws_profile: nil, aws_region: nil)
        @aws_profile = aws_profile
        @aws_region = aws_region
    end
end
