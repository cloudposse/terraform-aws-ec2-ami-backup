resource "aws_iam_role" "ami_backup_role" {
  name = "ami_backup_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ami_backup_policy" {
  name = "ami_backup_policy"
  role = "${aws_iam_role.ami_backup_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["logs:*"],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        }

    ]
}
EOF
}

data "archive_file" "ami_backups_zip" {
  type        = "zip"
  source_file = "lambdaAMIBackups.py"
  output_path = "lambdaAMIBackups.zip"
}

resource "aws_lambda_function" "lambdaAMIBackups" {
  filename         = "lambdaAMIBackups.zip"
  function_name    = "lambdaAMIBackups"
  description      = "Automatically backs up instances tagged with backup: true"
  role             = "${aws_iam_role.ami_backup_role.arn}"
  timeout          = 60
  handler          = "lambdaAMIBackups.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_backups_zip.output_base64sha256}"
}

/*
data "archive_file" "ami_janitor_zip" {
  type        = "zip"
  source_file = "ami-janitor.py"
  output_path = "ami-janitor.zip"
}
*/

resource "aws_lambda_function" "lambdaAMICleanup" {
  filename         = "lambdaAMIBackups.zip"
  function_name    = "lambdaAMICleanup"
  description      = "Cleans up old AMI backups"
  role             = "${aws_iam_role.ami_backup_role.arn}"
  timeout          = 60
  handler          = "lambdaAMICleanup.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_backups_zip.output_base64sha256}"
}

resource "aws_cloudwatch_event_rule" "create-ami" {
  name                = "create-ami"
  description         = "Schedule for ami snapshot backups"
  schedule_expression = "${var.ami_backups_schedule}"
}

resource "aws_cloudwatch_event_rule" "delete-ami" {
  name                = "delete-ami"
  description         = "Schedule for ami snapshot cleanup"
  schedule_expression = "${var.ami_janitor_schedule}"
}

resource "aws_cloudwatch_event_target" "schedule_ami_backups" {
  rule      = "${aws_cloudwatch_event_rule.create-ami.name}"
  target_id = "schedule_ami_backups"
  arn       = "${aws_lambda_function.lambdaAMIBackups.arn}"
}

resource "aws_cloudwatch_event_target" "schedule_ami_cleanups" {
  rule      = "${aws_cloudwatch_event_rule.delete-ami.name}"
  target_id = "ami_janitor"
  arn       = "${aws_lambda_function.lambdaAMICleanup.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_backup" {
  statement_id  = "AllowExecutionFromCloudWatch_schedule_ami_backups"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambdaAMIBackups.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.create-ami.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_cleanup" {
  statement_id  = "AllowExecutionFromCloudWatch_ami_janitor"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambdaAMICleanup.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.delete-ami.arn}"
}
