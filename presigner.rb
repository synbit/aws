require './lib/AwsS3'
require 'getoptlong'
require 'json'

def help
    puts <<-EOF
Usage: ruby presigner.rb [OPTION]=[VALUE] ...

DESCRIPTION

    Generate presigned URLs for S3 resources, specifying their expiry time in seconds (maximum 1 week).

OPTIONS

    --aws-profile, -i
            This is the name of the IAM role listed in the shared credentials file (~/.aws/credentials).
            This argument is mandatory.

    --aws-region, -r
            The AWS region where the S3 resource is in. This argument is mandatory.

    --s3-bucket, -b
            The name of the S3 bucket where the resource is in. This argument is mandatory.

    --s3-key, -k
            The name of the resource for which a presigned URL is going to be created. This argument is mandatory.

    --expires-in, -s
            Number of seconds after which the presigned URL will be invalid. Default value is 60 seconds.

    --help, -h
            Print this help message

AUTHOR / CONTRIBUTORS
    synbit

SOURCE
    https://github.com/synbit/aws
    EOF
    exit(0)
end

opts = GetoptLong.new(
    ['--aws-profile', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--aws-region', '-r', GetoptLong::REQUIRED_ARGUMENT],
    ['--s3-bucket', '-b', GetoptLong::REQUIRED_ARGUMENT],
    ['--s3-key', '-k', GetoptLong::REQUIRED_ARGUMENT],
    ['--expires-in', '-s', GetoptLong::REQUIRED_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

aws_profile, aws_region, s3_bucket, s3_key = nil
ttl = 60

opts.each do |opt, arg|
    case opt
    when '--help', '-h'
        help()
    when '--aws-profile', '-i'
        aws_profile = arg
    when '--aws-region', '-r'
        aws_region = arg
    when '--s3-bucket', '-b'
        s3_bucket = arg
    when '--s3-key', '-k'
        s3_key = arg
    when '--expires-in', '-s'
        ttl = arg.to_i
    end
end

if (aws_profile.nil? or aws_region.nil? or s3_bucket.nil? or s3_key.nil? or ttl.nil?)
    abort("Missing mandatory argument... Please use --help for a full list of options.")
end

presigner = AwsS3.new(
    aws_profile: aws_profile,
    aws_region: aws_region
)

url = presigner.presign_url(s3_bucket, s3_key, ttl)

res = {"S3 Bucket" => s3_bucket, "S3 Key" => s3_key, "URL" => url, "Expires In" => ttl}
puts(JSON.pretty_generate(res))
