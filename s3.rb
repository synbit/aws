require './lib/AwsS3'
require 'micro-optparse'

options = Parser.new do |p|
    p.banner = "Simple script to interact with AWS S3."
    p.version = "v0.0.1"
    p.option :action, "Should be one of [upload, download, create_bucket]", :default => "", :value_in_set => ["upload", "download", "create_bucket"]
    p.option :aws_profile, "The AWS profile to be used (from ~/.aws/credentials)", :default => "", :short => "p"
    p.option :aws_region, "AWS region to be used", :default => "", :short => "r"
    p.option :s3_bucket, "Name of the S3 bucket you want to use or create", :default => "", :short => "b"
    p.option :s3_key, "S3 key name. Specify if you uploading/downloading to/from S3", :default => "", :short => "k"
    p.option :local_path, "Full path of the resource to be uploaded/downloaded to/from S3", :default => "", :short => "P"
end.process!

action = options[:action]
aws_profile = options[:aws_profile]
aws_region = options[:aws_region]
s3_bucket = options[:s3_bucket]
s3_key = options[:s3_key]
local_path = options[:local_path]

s3 = AwsS3.new(
    aws_profile: aws_profile,
    aws_region: aws_region,
    s3_bucket: s3_bucket,
    s3_key: s3_key,
    local_path: local_path
)

begin
    action === "upload" && s3.upload && puts("Upload successful!")
    action === "download" && s3.download && puts("Download successful!")
    action === "create_bucket" && s3.create_bucket && puts("S3 bucket created successfully!")
rescue StandardError.new("Something went wrong...") => e
    puts("#{e.class}\n#{e.message}")
    raise
end
