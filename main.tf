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
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
      "ec2:ModifySnapshotAttribute",
      "ec2:ResetSnapshotAttribute"
    ]

    resources = [
      "*",
    ]
  }
}

data "archive_file" "ami_backups_zip" {
  type        = "zip"
  source_file = "${path.module}/ami_backup.py"
  output_path = "${path.module}/ami_backup.zip"
}

data "archive_file" "ami_cleanups_zip" {
  type        = "zip"
  source_file = "${path.module}/ami_backup.py"
  output_path = "${path.module}/ami_backup.zip"
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
  filename         = "${path.module}/lambda_ami_backups.zip"
  function_name    = "${module.label_backup.id}"
  description      = "Automatically backup instances tagged with 'backup: true'"
  role             = "${aws_iam_role.ami_backup.arn}"
  timeout          = 60
  handler          = "lambda_ami_backups.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_backups_zip.output_base64sha256}"

  environment = {
    variables = {
      region    = "${var.region}"
      ami_owner = "${var.ami_owner}"
    }
  }
}

resource "aws_lambda_function" "ami_cleanup" {
  filename         = "${path.module}/lambda_ami_cleanups.zip"
  function_name    = "${module.label_cleanup.id}"
  description      = "Cleanup old AMI backups"
  role             = "${aws_iam_role.ami_backup.arn}"
  timeout          = 60
  handler          = "lambda_ami_cleanups.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${data.archive_file.ami_cleanups_zip.output_base64sha256}"

  environment = {
    variables = {
      region    = "${var.region}"
      ami_owner = "${var.ami_owner}"
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
