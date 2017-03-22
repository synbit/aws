require './lib/AwsS3'
require 'getoptlong'

def help
    puts <<-EOF
Usage: ruby s3.rb [OPTION]=[VALUE] ...

OPTIONS

    --download, -d
            Flag to indicate that you wish to download the specified key, using --s3-key to the specified local path by --local-path.

    --upload, -u
            Flag to indicate that you wish to upload the specified resource, using --local-path to the specified S3 bucket, using --s3-key.

    --create-bucket, -c
            Flag to indicate that you wish to create a bucket, specified using --s3-bucket, in the region specified by --aws-region.

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
    ['--upload', '-u', GetoptLong::NO_ARGUMENT],
    ['--download', '-d', GetoptLong::NO_ARGUMENT],
    ['--create-bucket', '-c', GetoptLong::NO_ARGUMENT],
    ['--aws-profile', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--aws-region', '-r', GetoptLong::REQUIRED_ARGUMENT],
    ['--s3-bucket', '-b', GetoptLong::REQUIRED_ARGUMENT],
    ['--s3-key', '-k', GetoptLong::REQUIRED_ARGUMENT],
    ['--local-path', '-p', GetoptLong::REQUIRED_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

upload, download, create_bucket = false
aws_profile, aws_region, s3_bucket, s3_key, local_path = nil

opts.each do |opt, arg|
    case opt
    when '--help', '-h'
        help()
    when '--upload', '-u'
        upload = true
    when '--download', '-d'
        download = true
    when '--create-bucket', '-c'
        create_bucket = true
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

if (aws_profile.nil? && aws_region.nil? && s3_bucket.nil? && s3_key.nil? && local_path.nil?)
    puts("No arguments provided...")
    help()
end

s3 = AwsS3.new(
    aws_profile: aws_profile,
    aws_region: aws_region,
    s3_bucket: s3_bucket,
    s3_key: s3_key,
    local_path: local_path
)

begin
    download && s3.download(s3_key, local_path)
    upload && s3.upload(local_path, s3_key)
rescue StandardError.new("Something went wrong...") => e
    puts("#{e.class}\n#{e.message}")
    raise
end
