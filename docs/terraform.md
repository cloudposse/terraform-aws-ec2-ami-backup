
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami_owner | AWS Account ID which is used as a filter for AMI list (e.g. `123456789012`) | string | `` | no |
| backup_schedule | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | string | `cron(00 19 * * ? *)` | no |
| block_device_mappings | List of block device mappings to be included/excluded from created AMIs. With default value of [], AMIs will include all attached EBS volumes | list | `<list>` | no |
| cleanup_schedule | The scheduling expression. (e.g. cron(0 20 * * ? *) or rate(5 minutes) | string | `cron(05 19 * * ? *)` | no |
| instance_id | AWS Instance ID which is used for creating the AMI image (e.g. `id-123456789012`) | string | - | yes |
| name | Name  (e.g. `bastion` or `db`) | string | `` | no |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `` | no |
| reboot | Reboot the machine as part of the snapshot process | string | `false` | no |
| region | AWS Region where module should operate (e.g. `us-east-1`) | string | `` | no |
| retention_days | Is the number of days you want to keep the backups for (e.g. `14`) | string | `14` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `` | no |

