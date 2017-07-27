# Terraform config for automatic AMI create

This repo contains a terraform configuration that creates two lambda functions
that will take AMI automatic at regular intervals. It is based on
the code at
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups/> and
<https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups-2/>.

## Usage

Include this repository as a module in your existing terraform code:

```
module "lambda_ami_backup" {
  source = "github.com/cloudposse/tf_lambda_ami_backup"
  # Setting these variables is optional
  # ebs_snapshot_backups_schedule = "cron(00 19 * * ? *)"
  # ebs_snapshot_janitor_schedule = "cron(05 19 * * ? *)"
}
```

### Configuring your instances to be backed up

Tag any instances you want to be backed up with `Backup_AMI = true`.

By default, old backups will be removed after 7 days, to keep them longer, set
another tag: `Retention = 14`, where 14 is the number of days you want to keep
the backups for.
