require '.lib/AwsCloudFormation'
require '.lib/AwsS3'
require 'json'

iam = ENV['iam']
region = ENV['region']
stack = ENV['stack']
bucket = ENV['bucket']
src = ENV['file']
dst = ENV['key']

cf = AwsCloudFormation.new(
    aws_profile: iam,
    aws_region: region
)

s3 = AwsS3.new(
    aws_profile: iam,
    aws_region: region
)

desc "Default task, describes all tasks."
task :default do
    sh "rake -T"
end

desc "Describe a CloudFormation stack. Params: iam, region, stack"
task :describe_stack do
    puts("[#{Time.now.iso8601}] Retrieving stack information...")
    res = cf.describe_stack(stack)
    puts(JSON.pretty_generate(res))
    puts("[#{Time.now.iso8601}] Finished.")
end

desc "Create a CloudFormation stack. Params: iam, region, stack, bucket."
task :create_stack => :validate_template do
    puts("[#{Time.now.iso8601}] Building stack...")
    url = s3.presign_url(bucket, "#{stack_name}/#{stack_name}.template", 60)
    cf.create_stack(stack, url)
    puts("[#{Time.now.iso8601}] Stack created successfully. Build finished.")
end

desc "Update an existing CloudFormation stack. Params: iam, region, stack, bucket"
task :update_stack => :validate_template do
    puts("[#{Time.now.iso8601}] Stack update started...")
    url = s3.presign_url(bucket, "#{stack_name}/#{stack_name}.template", 60)
    cf.update_stack(stack, url)
    puts("[#{Time.now.iso8601}] Stack updated finished.")
end

desc "Upload a tamplate to S3. Params: iam, region, src, dst."
task :upload_template do
    puts("[#{Time.now.iso8601}] Uploading to S3...")
    s3.upload(src, dst)
    puts("[#{Time.now.iso8601}] Finished uploading.")
end

desc "Validate a CloudFormation template. Params: iam, region, stack, bucket."
task :validate_template do
    puts("[#{Time.now.iso8601}] Template validation started...")
    url = s3.presign_url(bucket, "#{stack_name}/#{stack_name}.template", 60)
    cf.validate_template(url)
    puts("[#{Time.now.iso8601}] Validation finished.")
end
