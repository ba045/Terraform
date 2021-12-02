resource "aws_iam_role" "role_backup" {
  name = "${format("%s-role-backup", var.name)}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy_backup" {
  name = "${format("%s-policy-backup", var.name)}"
  role = aws_iam_role.role_backup.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "dlm_policy_backup" {
  description = "${format("%s-dlm-policy-backup", var.name)}"
  execution_role_arn = aws_iam_role.role_backup.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "${format("%s-schedule-backup", var.name)}"

      create_rule {
        interval      = var.backup.interval
        interval_unit = var.backup.interval_unit
        times         = var.backup.times
      }
      retain_rule {
        count = var.backup.count
      }
      tags_to_add = {
        SnapshotCreator = "DLM"
      }
      copy_tags = true
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}