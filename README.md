# Terraform module for automatic AMI creation

**WARNING!** AMI cleanup works not yet.

This repo contains a terraform module that creates two lambda functions
that will create AMI automatically at regular intervals. It is based on
the code at
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups/> and
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups-2/>.

## Usage

Include this repository as a module in your existing terraform code:

Notes:
* `ami_owner` is an AWS account id.

```
module "lambda_ami_backup" {
  source            = "git::https://github.com/cloudposse/tf_lambda_ami_backup.git?ref=master"
  name              = "${var.name}"
  stage             = "${var.stage}"
  namespace         = "${var.namespace}"
  region            = "${var.region}"
  ami_owner         = "${var.ami_owner}"
}
```


## Variables

|  Name                        |  Default       |  Description                                              | Required |
|:----------------------------:|:--------------:|:--------------------------------------------------------:|:--------:|
| namespace                    | ``             | Namespace (e.g. `cp` or `cloudposse`)                    | Yes      |
| stage                        | ``             | Stage (e.g. `prod`, `dev`, `staging`                     | Yes      |
| name                         | ``             | Name  (e.g. `bastion` or `db`)                           | Yes      |
| region                       | ``             | AWS Region where module should operate (e.g. `us-east-1`)| Yes      |
| ami_owner                    | ``             | AWS Account ID which is used as a filter for AMI list (e.g. `123456789012`)| Yes      |
| backup_schedule              | `cron(00 19 * * ? *)` | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | No       |
| cleanup_schedule             | `cron(05 19 * * ? *)` | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | No       |


## Configuring your instances to be backed up

Tag any instances you want to be backed up with `Snapshot = true`.

By default, old backups will be removed after 7 days, to keep them longer, set
another tag: `Retention = 14`, where 14 is the number of days you want to keep
the backups for.
