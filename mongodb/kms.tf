resource "aws_kms_key" "kms_key" {
  count       = var.encrypted ? 1 : 0
  description = "KMS key for RDS"
  tags        ={"Name" : "nw-social-mongodb-kms"}
}
