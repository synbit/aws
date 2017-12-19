#!/usr/bin/env python

import sys
import getopt
import boto3
import json

iam = region = None
opts, args = getopt.getopt(sys.argv[1:], "i:r:h", ["iam=", "region=", "help"])

def print_help_and_exit(exit_code):
    msg = """SYNOPSIS

    get_latest_ami.py [OPTION]=[VALUE]

DESCRIPTION

    Get the latest Amazon Linux AMI available on a given AWS Region.

USAGE

    get_latest_ami.py --iam=<iam> --region=<region>

OPTIONS

    --iam=, -i
        AWS Access Key to be used for this operation.

    --region=, -r
        AWS Region to get the latest Amazon Linux AMI for.

    --help, -h
        Print this help menu and exit.
          """
    print(msg)
    sys.exit(exit_code)

def get_latest_ami(ec2_client):
    amis = {}
    res = ec2_client.describe_images(
        Filters = [
            {
                'Name': 'architecture',
                'Values': ['x86_64']
            },
            {
                'Name': 'virtualization-type',
                'Values': ['hvm']
            },
            {
                'Name': 'name',
                'Values': ['amzn-ami-hvm-????.??.?.????????-x86_64-gp2']
            }
        ],
        Owners = ['amazon']
    )
    for i in res['Images']:
        amis[i['CreationDate']] = i['ImageId']

    return amis[sorted(amis, reverse=True)[0]]

for opt in opts:
    if opt[0] == '--help' or opt[0] == '-h':
        print_help_and_exit(0)
    elif opt[0] == '--iam' or opt[0] == '-i':
        iam = opt[1]
    elif opt[0] == '--region' or opt[0] == '-r':
        region = opt[1]
    else:
        sys.exit(print_help_and_exit(1))

session = boto3.Session(profile_name=iam, region_name=region)
ec2 = session.client('ec2', region_name=region)
print(json.dumps({'Region': region, 'Ami': get_latest_ami(ec2)}, indent=2))
