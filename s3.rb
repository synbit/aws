require './lib/AwsS3'
require 'getoptlong'

def help
    puts <<-EOF
Usage: ruby s3.rb [OPTION]=[VALUE] ...

OPTIONS

    --action, -a
            One of [upload, download, create].
            upload  : upload a resource on S3. To be used alongside --aws_profile, --aws_region, --s3-bucket, --s3-key, --local-path.
            download: download a resource from S3. To be used alongside --aws_profile, --aws_region, --s3-bucket, --s3-key, --local-path.
            create  : create an S3 bucket. To be used alongside --aws-profile, --aws-region, --s3-bucket

    --aws-profile, -i
            This is the name of the IAM role listed in the shared credentials file (~/.aws/credentials).

    --aws-region, -r
            The AWS region where the S3 resource will be uploaded (--action=upload), downloaded (--action=download) from, or the region
            where the S3 bucket is going to be created (--action=create).

    --s3-bucket, -b
            The name of the S3 bucket to be created (--action=create).

    --s3-key, -k
            The name of the resource to be uploaded (--action=upload) or downloaded (--action=download) form the S3 bucket specified (--s3-bucket).

    --local-path, -p
            The local path to the resource you wish to upload (--action=upload) to an S3 bucket, or the local path where you wish to download (--action=download)
            from an S3 bucket. The S3 bucket is specified with --s3-bucket in both cases.

    --help, -h
            Print this help message

AUTHOR / CONTRIBUTORS
    synbit

SOURCE
    https://github.com/synbit/aws
    EOF
end

opts = GetoptLong.new(
    ['--action', '-a', GetoptLong::REQUIRED_ARGUMENT],
    ['--aws-profile', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--aws-region', '-r', GetoptLong::REQUIRED_ARGUMENT],
    ['--s3-bucket', '-b', GetoptLong::REQUIRED_ARGUMENT],
    ['--s3-key', '-k', GetoptLong::REQUIRED_ARGUMENT],
    ['--local-path', '-p', GetoptLong::REQUIRED_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

action, aws_profile, aws_region, s3_bucket, s3_key, s3_path, local_path = nil

opts.each do |opt, arg|
    case opt
    when '--help', '-h'
        help()
    when '--action', '-a'
        action = arg
    when '--aws-profile', '-i'
        aws_profile = arg
    when '--aws-region', '-r'
        aws_region = arg
    when '--s3-bucket', '-b'
        s3_bucket = arg
    when '--s3-key', '-k'
        s3_key = arg
    when '--local-path', '-p'
        local_path = arg
    end
end

if (action.nil? && aws_profile.nil? && aws_region.nil? && s3_bucket.nil? && s3_key.nil? && local_path.nil?)
    puts("No arguments provided...")
    help()
end

s3 = AwsS3.new(
    aws_profile: aws_profile,
    aws_region: aws_region,
    s3_bucket: s3_bucket,
    s3_key: s3_key,
    s3_path: s3_path,
    local_path: local_path
)

begin
    s3.download(s3_key, local_path)
    action === "upload" && s3.upload && puts("Upload successful!")
    action === "create_bucket" && s3.create_bucket && puts("S3 bucket created successfully!")
rescue StandardError.new("Something went wrong...") => e
    puts("#{e.class}\n#{e.message}")
    raise
end
