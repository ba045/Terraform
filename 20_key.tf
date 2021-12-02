resource "aws_key_pair" "key_pair" {
  key_name   = var.key.name
  public_key = var.key.public
}