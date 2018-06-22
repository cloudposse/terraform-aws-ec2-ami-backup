# See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
# for how to write schedule expressions
variable "backup_schedule" {
  default = "cron(00 19 * * ? *)"
}

variable "cleanup_schedule" {
  default = "cron(05 19 * * ? *)"
}

variable "ami_owner" {
  default = ""
}

variable "region" {
  default = ""
}

variable "retention_days" {}

variable "instance_id" {}

variable "block_device_mappings" {
  description = "List of block device mappings to be included/excluded from created AMIs"
  type        = "list"
  default     = []
}

variable "name" {
  default = ""
}

variable "namespace" {
  default = ""
}

variable "stage" {
  default = ""
}

variable "reboot" {
  default = "false"
}
