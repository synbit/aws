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

    def create_stack(stack, cftemplate_url, params = []) # add params and load it from disk
        begin
            cf_api.create_stack({
                stack_name: stack,
                template_url: cftemplate_url,
                # parameters: [
                #     {
                #         parameter_key: "ParameterKey1",
                #         parameter_value: "ParameterValue1"
                #     },
                #     {
                #         parameter_key: "ParameterKey2",
                #         parameter_value: "ParameterValue2"
                #     }
                # ],
                resource_types: ["AWS::*"],
                on_failure: "ROLLBACK",
                tags: [
                    {
                        key: "Environment",
                        value: "Development"
                    },
                    {
                        key: "CreatedAt",
                        value: Time.now.iso8601
                    }
                ]
            })
            cf_api.wait_until(:stack_create_complete)
            puts("Stack created successfully.")
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}")
            raise
        ensure
            puts("Stack => #{stack}")
        end
    end

    def update_stack(stack, cftemplate_url, params)
        begin
            cf_api.update_stack({
                stack_name: stack,
                template_url: cftemplate_url,
                # parameters: [
                #     {
                #         parameter_key: "ParameterKey",
                #         parameter_value: "ParameterValue"
                #     },
                #     {
                #         parameter_key: "ParameterKey",
                #         parameter_value: "ParameterValue"
                #     }
                # ],
                resource_types: ["AWS::*"],
                on_failure: "ROLLBACK",
                tags: [
                    {
                        key: "Environment",
                        value: "Development"
                    },
                    {
                        key: "UpdatedAt",
                        value: Time.now.iso8601
                    }
                ]
            })
            cf_api.wait_until(:stack_update_complete)
            puts("Stack update complete.")
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
