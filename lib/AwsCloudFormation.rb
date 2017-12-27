class AwsCloudFormation
    require 'aws-sdk'
    require 'time'
    require 'colorize'
    require 'os'

    Aws.use_bundled_cert! if OS.windows?

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
            puts("Stack '#{stack}' does not exist.".yellow)
            return {}
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}".red)
            raise
        ensure
            puts("Stack => #{stack}".blue)
        end
    end

    def create_stack(stack, cftemplate_url, params) # add parameter for environment tag
        begin
            cf_api.create_stack({
                stack_name: stack,
                template_url: cftemplate_url,
                parameters: params,
                capabilities: ["CAPABILITY_IAM"],
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
            cf_api.wait_until(:stack_create_complete, stack_name: stack)
            puts("Stack created successfully.".green)
        rescue Aws::CloudFormation::Errors::ServiceError => e
            puts("CloudFormation Exception details:\n\t#{e.class}\n\t#{e.message}".red)
            raise
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}".red)
            raise
        ensure
            puts("Stack => #{stack}".blue)
        end
    end

    def update_stack(stack, cftemplate_url, params) # add parameter for environment tag
        begin
            cf_api.update_stack({
                stack_name: stack,
                template_url: cftemplate_url,
                parameters: params,
                capabilities: ["CAPABILITY_IAM"],
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
            cf_api.wait_until(:stack_update_complete, stack_name: stack)
            puts("Stack update complete.".green)
        rescue Aws::CloudFormation::Errors::ServiceError => e
            if e.message === "No updates are to be performed."
                puts(e.message.yellow)
            else
                puts("CloudFormation Exception details:\n\t#{e.class}\n\t#{e.message}".red)
                raise
            end
        rescue StandardError => e
            puts("Exception details:\n\t#{e.class}\n\t#{e.message}".yellow)
            raise
        ensure
            puts("Stack => #{stack}".blue)
        end
    end

    private
    def load_profile
        profile = Aws::SharedCredentials.new(
            profile_name: profile.credentials,
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
