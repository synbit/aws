class AwsCloudFormation
    require 'aws-sdk'
    require 'time'

    attr_accessor :aws_profile, :aws_region

    def initialize(aws_profile: nil, aws_region: nil)
        @aws_profile = aws_profile
        @aws_region = aws_region
    end

    def validate_template(cftemplate_url)
        cf_api.validate_template({
            template_url: cftemplate_url
        })
    end

    private
    def load_profile
        profile = Aws::SharedCredentials.new(
            profile_name: @aws_profile,
            region: @aws_region
        )
    end

    def cf_api
        profile = load_profile
        cf = Aws::CloudFormation::Client.new(
            region: @aws_region,
            credentials: profile.credentials
        )
    end
end
