require './lib/AwsCloudFormation'
require './lib/AwsS3'
require 'json'
require 'colorize'

iam = ENV['iam']
region = ENV['region']
stack = ENV['stack']
bucket = ENV['bucket']
src = ENV['file']
dst = ENV['key']
params = ENV['params']

cf = AwsCloudFormation.new(
    aws_profile: iam,
    aws_region: region
)

s3 = AwsS3.new(
    aws_profile: iam,
    aws_region: region
)

def sanitise(task, args_hash)
    args_hash.values.each do |v|
        abort("Task/Dependant Task: #{task}\nParameters required: #{args_hash.keys}.".yellow) if v.nil?
    end
end

desc "Default task, describes all tasks."
task :default do
    sh "rake -T"
end

desc "Describe a CloudFormation stack. Params: iam, region, stack"
task :describe_stack do |task_name|
    sanitise(task_name, {iam: iam, region: region, stack: stack})
    puts("[#{Time.now.iso8601}] Retrieving stack information...".blue)
    res = cf.describe_stack(stack)
    puts(JSON.pretty_generate(res))
    puts("[#{Time.now.iso8601}] Finished.".green)
end

desc "Create or updated a stack. Params: iam, region, stack, bucket, params."
task :build do |task_name|
    sanitise(task_name, {iam: iam, region: region, stack: stack, params: params, bucket: bucket})
    desc = cf.describe_stack(stack)
    if (desc["Status"].nil?)
        Rake::Task["create_stack"].execute
    elsif (desc.keys.include?("Status"))
        Rake::Task["update_stack"].execute
    end
end

desc "Create a CloudFormation stack. Params: iam, region, stack, bucket, params."
task :create_stack => :validate_template do |task_name|
    sanitise(task_name, {iam: iam, region: region, stack: stack, params: params, bucket: bucket})
    puts("[#{Time.now.iso8601}] Creating stack...".blue)
    params_hash = JSON.parse(File.read(params))
    url = s3.presign_url(bucket, "#{stack}/#{stack}.template", 60)
    cf.create_stack(stack, url, params_hash)
    puts("[#{Time.now.iso8601}] Build finished.".green)
end

desc "Update an existing CloudFormation stack. Params: iam, region, stack, bucket"
task :update_stack => :validate_template do |task_name|
    sanitise(task_name, {iam: iam, region: region, stack: stack, params: params, bucket: bucket})
    puts("[#{Time.now.iso8601}] Updating stack...".blue)
    params_hash = JSON.parse(File.read(params))
    url = s3.presign_url(bucket, "#{stack}/#{stack}.template", 60)
    cf.update_stack(stack, url, params_hash)
    puts("[#{Time.now.iso8601}] Build finished.".green)
end

desc "Upload a tamplate to S3. Params: iam, region, src, dst."
task :upload_template do |task_name|
    sanitise(task_name, {iam: iam, src: src, dst: dst})
    puts("[#{Time.now.iso8601}] Uploading to S3...".blue)
    s3.upload(src, dst)
    puts("[#{Time.now.iso8601}] Finished uploading.".green)
end

desc "Validate a CloudFormation template. Params: iam, region, stack, bucket."
task :validate_template do |task_name|
    sanitise(task_name, {iam: iam, stack: stack, bucket: bucket})
    puts("[#{Time.now.iso8601}] Template validation started...".blue)
    url = s3.presign_url(bucket, "#{stack}/#{stack}.template", 60)
    cf.validate_template(url)
    puts("[#{Time.now.iso8601}] Validation finished.".green)
end
