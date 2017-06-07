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

    def describe_stack(stack)
        inner = {}
        output = {}
        begin
            res = cf_api.describe_stacks({
                stack_name: stack
            })
            res.stacks[0].tags.each do |tag|
                inner[tag.key] = tag.value
            end
            output["Status"] = res.stacks[0].stack_status
            output["Tags"] = inner
            output
        rescue Aws::CloudFormation::Errors::ValidationError => e
            puts("Describe failed. Stack '#{stack}' does not exist.")
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}")
            raise
        ensure
            puts("Stack => #{stack}")
        end
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
