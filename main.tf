data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "ami_backup" {
  statement {
    actions = [
      "logs:*",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:CreateImage",
      "ec2:DescribeImages",
      "ec2:DeregisterImage",
      "ec2:DescribeSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
    ]

    resources = [
      "*",
    ]
  }
}

data "archive_file" "ami_backup" {
  type        = "zip"
  source_file = "${path.module}/ami_backup.py"
  output_path = "${path.module}/ami_backup.zip"
}

data "archive_file" "ami_cleanup" {
  type        = "zip"
  source_file = "${path.module}/ami_cleanup.py"
  output_path = "${path.module}/ami_cleanup.zip"
}

module "label" {
  source    = "git::https://github.com/cloudposse/tf_label.git?ref=tags/0.1.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
}

module "label_backup" {
  source    = "git::https://github.com/cloudposse/tf_label.git?ref=tags/0.1.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}-backup"
}

module "label_cleanup" {
  source    = "git::https://github.com/cloudposse/tf_label.git?ref=tags/0.1.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}-cleanup"
}

resource "aws_iam_role" "ami_backup" {
  name               = "${module.label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role_policy" "ami_backup" {
  name   = "${module.label.id}"
  role   = "${aws_iam_role.ami_backup.id}"
  policy = "${data.aws_iam_policy_document.ami_backup.json}"
}

resource "aws_lambda_function" "ami_backup" {
  filename         = "${path.module}/ami_backup.zip"
  function_name    = "${module.label_backup.id}"
  description      = "Automatically backup EC2 instance ${var.instance_id} (create AMI)"
  role             = "${aws_iam_role.ami_backup.arn}"
  timeout          = 60
  handler          = "ami_backup.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_backup.output_base64sha256}"

  environment = {
    variables = {
      region      = "${var.region}"
      ami_owner   = "${var.ami_owner}"
      instance_id = "${var.instance_id}"
      retention   = "${var.retention_days}"
      label_id    = "${module.label.id}"
    }
  }
}

resource "aws_lambda_function" "ami_cleanup" {
  filename         = "${path.module}/ami_cleanup.zip"
  function_name    = "${module.label_cleanup.id}"
  description      = "Cleanup old AMI backups"
  role             = "${aws_iam_role.ami_backup.arn}"
  timeout          = 60
  handler          = "ami_cleanup.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_cleanup.output_base64sha256}"

  environment = {
    variables = {
      region    = "${var.region}"
      ami_owner = "${var.ami_owner}"
      label_id  = "${module.label.id}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "ami_backup" {
  name                = "${module.label_backup.id}"
  description         = "Schedule for AMI snapshot backups"
  schedule_expression = "${var.backup_schedule}"
}

resource "aws_cloudwatch_event_rule" "ami_cleanup" {
  name                = "${module.label_cleanup.id}"
  description         = "Schedule for AMI snapshot cleanup"
  schedule_expression = "${var.cleanup_schedule}"
}

resource "aws_cloudwatch_event_target" "ami_backup" {
  rule      = "${aws_cloudwatch_event_rule.ami_backup.name}"
  target_id = "${module.label_backup.id}"
  arn       = "${aws_lambda_function.ami_backup.arn}"
}

resource "aws_cloudwatch_event_target" "ami_cleanup" {
  rule      = "${aws_cloudwatch_event_rule.ami_cleanup.name}"
  target_id = "${module.label_cleanup.id}"
  arn       = "${aws_lambda_function.ami_cleanup.arn}"
}

resource "aws_lambda_permission" "ami_backup" {
  statement_id  = "${module.label_backup.id}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ami_backup.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ami_backup.arn}"
}

resource "aws_lambda_permission" "ami_cleanup" {
  statement_id  = "${module.label_cleanup.id}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ami_cleanup.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ami_cleanup.arn}"
}
