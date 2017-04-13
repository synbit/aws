require './lib/AwsEC2'

aws_profile = "bla"
aws_region = "bla"

ec2 = AwsEC2.new(
    aws_profile: aws_profile,
    aws_region: aws_region
)

res = ec2.get_non_elb_instances

if res.count === 0
    puts("There are no non-ELB asociated instances found.")
else
    puts("List of stand-alone instances (non-ELB members):\n#{res}")
end
