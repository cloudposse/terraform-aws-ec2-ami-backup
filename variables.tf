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

variable "retention_days" {
  default = ""
}

variable "instance_id" {
  default = ""
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
