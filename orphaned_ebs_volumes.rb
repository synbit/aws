require './lib/AwsEC2'
require 'getoptlong'

def help
    puts <<-EOF
NAME
    ec2_unattached_volumes - Find unattached EC2 volumes on AWS

SYNOPSIS
    ruby ec2_unattached_volumes [options]

DESCRIPTION
    ec2_unattached_volumes searches all EC2 volumes with "status": "available" against an AWS and reports the findings.
    It requires AWS Shared Credentials to be setup on the local machine ($HOME/.aws/credentials).

OPTIONS
    --aws-profile, -i
            This is the name of the IAM role listed in the shared credentials file (~/.aws/credentials).

    --aws-region, -r
            The AWS region where you want to search for "available" EC2 volumes.

    --help, -h
            Print this help message

AUTHORS / CONTRIBUTORS
    synbit

SOURCE
    https://github.com/synbit/aws
EOF
end

opts = GetoptLong.new(
    ['--aws-profile', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--aws-region', '-r', GetoptLong::REQUIRED_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

aws_profile, aws_region = nil

opts.each do |opt, arg|
    case opt
    when '--help', '-h'
        help()
    when '--aws-profile', '-i'
        aws_profile = arg
    when '--aws-region', '-r'
        aws_region = arg
    end
end

if (aws_profile.nil? or aws_region.nil?)
    abort(help())
end

ec2 = AwsEC2.new(
    aws_profile: aws_profile,
    aws_region: aws_region
)

volumes = ec2.get_orphaned_ebs_volumes

if (volumes.count > 0)
    puts("Unattached volumes found: #{volumes.count}.")
    puts(volumes)
else
    puts("No unattached volumes found.")
end
