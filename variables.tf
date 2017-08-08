# See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
# for how to write schedule expressions
variable "backups_schedule" {
  default = "cron(00 19 * * ? *)"
}

variable "cleanups_schedule" {
  default = "cron(05 19 * * ? *)"
}

variable "ami_owner" {
  default = ""
}

variable "region" {
  default = "us-east-1"
}

variable "retention" {
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
