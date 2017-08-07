resource "aws_iam_role" "ami_backup" {
  name = "${module.tf_label.id}"

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

resource "aws_iam_role_policy" "ami_backup" {
  name = "${module.tf_label.id}"
  role = "${aws_iam_role.ami_backup.id}"

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
  source_file = "${path.module}/lambda_ami_backups.py"
  output_path = "${path.module}/lambda_ami_backups.zip"
}

resource "aws_lambda_function" "lambda_ami_backups" {
  filename         = "${path.module}/lambda_ami_backups.zip"
  function_name    = "${module.tf_label.id}_backups"
  description      = "Automatically backs up instances tagged with backup: true"
  role             = "${aws_iam_role.ami_backup.arn}"
  timeout          = 60
  handler          = "lambda_ami_backups.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_backups_zip.output_base64sha256}"
  environment = {
    variables = {
      region = "${var.region}"
      ami_owner = "${var.ami_owner}"
    }
  }
}

data "archive_file" "ami_cleanups_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_ami_cleanups.py"
  output_path = "${path.module}/lambda_ami_cleanups.zip"
}

resource "aws_lambda_function" "lambda_ami_cleanups" {
  filename         = "${path.module}/lambda_ami_cleanups.zip"
  function_name    = "${module.tf_label.id}_cleanups"
  description      = "Cleans up old AMI backups"
  role             = "${aws_iam_role.ami_backup.arn}"
  timeout          = 60
  handler          = "lambda_ami_cleanups.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_cleanups_zip.output_base64sha256}"
  environment = {
    variables = {
      region = "${var.region}"
      ami_owner = "${var.ami_owner}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "create_ami" {
  name                = "${module.tf_label.id}_create_ami"
  description         = "Schedule for ami snapshot backups"
  schedule_expression = "${var.ami_backups_schedule}"
}

resource "aws_cloudwatch_event_rule" "delete_ami" {
  name                = "${module.tf_label.id}_delete_ami"
  description         = "Schedule for ami snapshot cleanup"
  schedule_expression = "${var.ami_cleanups_schedule}"
}

resource "aws_cloudwatch_event_target" "schedule_ami_backups" {
  rule      = "${aws_cloudwatch_event_rule.create_ami.name}"
  target_id = "schedule_ami_backups"
  arn       = "${aws_lambda_function.lambda_ami_backups.arn}"
}

resource "aws_cloudwatch_event_target" "schedule_ami_cleanups" {
  rule      = "${aws_cloudwatch_event_rule.delete_ami.name}"
  target_id = "schedule_ami_cleanups"
  arn       = "${aws_lambda_function.lambda_ami_cleanups.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_backup" {
  statement_id  = "AllowExecutionFromCloudWatch_schedule_ami_backups"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_ami_backups.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.create_ami.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_cleanup" {
  statement_id  = "AllowExecutionFromCloudWatch_schedule_ami_cleanups"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_ami_cleanups.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.delete_ami.arn}"
}
