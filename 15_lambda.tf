# CloudWatch Log groups >>> Lambda >>> S3

resource "aws_iam_role" "role_log_cw_s3" {
  name = "${format("%s-role-log-cw-s3", var.name)}"
  path = "/"

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
resource "aws_iam_role_policy" "policy_log_cw_s3" { 
  name = "${format("%s-policy-log-s3", var.name)}"
  role = aws_iam_role.role_log_cw_s3.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "logs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "lambda_permission_cw_s3" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_cw_s3.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

resource "aws_lambda_function" "lambda_function_cw_s3" {
  filename      = "${var.lambda.cw_s3}.zip"
  function_name = "${var.name}-cw-s3"
  role          = aws_iam_role.role_log_cw_s3.arn
  handler       = "${var.lambda.cw_s3}.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${var.lambda.cw_s3}.zip")

  runtime = "python3.7"

  environment {
    variables = {
      DESTINATION_BUCKET = "${format("%s-log-bucket123", var.name)}"
      GROUP_NAME = "${format("%s-log-group", var.name)}"
      NDAYS = "1"
      PREFIX = "Logs"
    }
  }
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "${format("%s-event-rule", var.name)}"
  description = "Event occurs at 9am every day."

  schedule_expression = "cron(30 0 * * ? *)"  # Every day at 9am.
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "${format("%s-cw-s3", var.name)}"
  arn       = aws_lambda_function.lambda_function_cw_s3.arn
}

# S3 Bucket >>> Lambda >>> SES
resource "aws_iam_role" "role_s3_ses" {
  name = "${format("%s-role-s3-ses", var.name)}"
  path = "/"

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
resource "aws_iam_role_policy" "policy_s3_ses" {
  name = "${format("%s-policy-s3-ses", var.name)}"
  role = aws_iam_role.role_s3_ses.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ses:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "lambda_permission_s3_ses" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_s3_ses.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.log_bucket.arn
}

resource "aws_lambda_function" "lambda_function_s3_ses" {
  filename      = "${var.lambda.s3_ses}.zip"
  function_name = "${var.name}-s3-ses"
  role          = aws_iam_role.role_s3_ses.arn
  handler       = "${var.lambda.s3_ses}.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${var.lambda.s3_ses}.zip")

  runtime = "python3.7"

  environment {
    variables = {
      TO_EMAILS = var.email.to
      SOURCE_EMAIL = var.email.source
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.log_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function_s3_ses.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "EC2Logs"
  }

  depends_on = [aws_lambda_permission.lambda_permission_s3_ses]
}

resource "aws_ses_email_identity" "source_email_identity" {
  email = var.email.source
}

resource "aws_ses_email_identity" "to_email_identity" {
  count = "${length(split(" ", var.email.to))}"
  email = "${element(split(" ", var.email.to), count.index)}"
}