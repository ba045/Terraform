resource "aws_s3_bucket" "log_bucket" {
    bucket = "${format("%s-log-bucket123", var.name)}"
    acl = "public-read-write"
    force_destroy = true
}
resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "${data.aws_elb_service_account.elb_account.arn}"
          ]
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.log_bucket.arn}/*"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.log_bucket.arn}/*",
        "Condition": {
          "StringEquals": {
            "s3:x-amz-acl": "bucket-owner-full-control"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "${aws_s3_bucket.log_bucket.arn}"
      },
      {
        "Effect": "Allow",
        "Principal": {
            "Service": "logs.${var.region.region}.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "${aws_s3_bucket.log_bucket.arn}"
      },
      {
        "Effect": "Allow",
        "Principal": {
            "Service": "logs.${var.region.region}.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "${aws_s3_bucket.log_bucket.arn}/*",
        "Condition": {
            "StringEquals": {
                "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
      }
    ]
  })
}
resource "aws_s3_bucket_public_access_block" "access_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_ebs_volume" "ebs" {
  availability_zone = "${var.region.region}${var.region.az[0]}"
  size              = 20

  tags = {
    Name = "${format("%s-ebs", var.name)}"
  }
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.bastion.id
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${format("%s-efs123", var.name)}"

  tags = {
    Name = "${format("%s-efs", var.name)}"
  }
}
resource "aws_efs_mount_target" "efs_mount" {
    count = "${length(var.cidr.was)}"
    file_system_id = aws_efs_file_system.efs.id
    subnet_id = "${aws_subnet.was_subnet[count.index].id}"
    security_groups = [aws_security_group.security_efs.id]
}