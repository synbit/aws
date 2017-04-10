require 'aws-sdk'

iam = 'xxx'
region = 'yyy'
vols = []
profile = Aws::SharedCredentials.new(profile_name: iam)
ec2 = Aws::EC2::Client.new( region: region, credentials: profile.credentials )
ec2.describe_volumes({ filters: [{name: "status", values: ["available"]}] }).volumes.map { |v| vols << v.volume_id }
