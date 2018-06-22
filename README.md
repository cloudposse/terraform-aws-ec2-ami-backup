# Terraform module for automatic AMI creation

This repo contains a terraform module that creates two lambda functions
that will create AMI automatically at regular intervals. It is based on
the code at
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups/> and
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups-2/>.

## Usage

Include this repository as a module in your existing terraform code:

```
module "lambda_ami_backup" {
  source = "git::https://github.com/cloudposse/tf_ami_backup.git?ref=tags/0.1.0"

  name              = "${var.name}"
  stage             = "${var.stage}"
  namespace         = "${var.namespace}"
  region            = "${var.region}"
  ami_owner         = "${var.ami_owner}"
  instance_id       = "${var.instance_id}"
  retention_days    = "14"

  block_device_mappings = [
    { "DeviceName" = "/dev/xvdf", "NoDevice" = "" },
    { "DeviceName" = "/dev/xvdg", "NoDevice" = "" },
  ]
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
| instance_id                  | ``             | AWS Instance ID which is used for creating the AMI image (e.g. `id-123456789012`)| Yes      |
| retention_days               | `14`           | Is the number of days you want to keep the backups for (e.g. `14`)| No     |
| backup_schedule              | `cron(00 19 * * ? *)` | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | No       |
| cleanup_schedule             | `cron(05 19 * * ? *)` | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | No       |
| reboot                       | `false`        | Reboot the machine as part of the snapshot process       | No       |
| block_device_mappings        | `[]`           | List of block device mappings to be included/excluded from created AMIs       | No       |
