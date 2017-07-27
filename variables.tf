# See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
# for how to write schedule expressions
variable "ami_backups_schedule" {
  default = "cron(00 19 * * ? *)"
}

variable "ami_janitor_schedule" {
  default = "cron(05 19 * * ? *)"
}
