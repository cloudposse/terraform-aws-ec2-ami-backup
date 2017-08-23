# Automated AMI Backups
#
# @author Robert Kozora <bobby@kozora.me>
#
# "retention_days" is environment variable which will be used as a retention policy number in days. If there is no
# environment variable with that name, it will use a 14 days default value for each AMI.
#
# After creating the AMI it creates a "AMIDeleteOn" tag on the AMI indicating when
# it will be deleted using the Retention value and another Lambda function 

from __future__ import print_function
import boto3
import collections
import datetime
import sys
import pprint
import os

ec = boto3.client('ec2')
ec2_instance_id = os.environ['instance_id']
label_id = os.environ['label_id']


def lambda_handler(event, context):
    try:
        retention_days = int(os.environ['retention'])
    except ValueError:
        retention_days = 14
    create_time = datetime.datetime.now()
    create_fmt = create_time.strftime('%Y-%m-%d')

    AMIid = ec.create_image(InstanceId=ec2_instance_id,
                            Name=label_id + "-" + ec2_instance_id + "-" + create_fmt,
                            Description=label_id + "-" + ec2_instance_id + "-" + create_fmt,
                            NoReboot=True, DryRun=False)

    print("Retaining AMI %s of instance %s for %d days" % (
        AMIid['ImageId'],
        ec2_instance_id,
        retention_days,
    ))

    delete_date = datetime.date.today() + datetime.timedelta(days=retention_days)
    delete_fmt = delete_date.strftime('%m-%d-%Y')

    ec.create_tags(
        Resources=[ec2_instance_id, AMIid['ImageId']],
        Tags=[
            {'Key': 'AMIDeleteOn', 'Value': delete_fmt},
        ]
    )
