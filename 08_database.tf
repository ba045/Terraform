resource "aws_db_instance" "database" {
    allocated_storage      = var.database.allocated_storage
    engine                 = var.database.engine
    engine_version         = var.database.engine_version
    instance_class         = var.database.instance_class
    multi_az               = var.database.multi_az
    name                   = var.database.name
    username               = var.database.username
    password               = var.database.password
    db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids = [aws_security_group.security_db.id]
    //availability_zone      = "${var.region.region}${var.region.az[0]}"
    identifier             = "${format("%s-db", var.name)}"
    enabled_cloudwatch_logs_exports = ["error", "audit", "general", "slowquery"]
    skip_final_snapshot    = true
    backup_window          = var.database.backup_window
    backup_retention_period = 4
    apply_immediately      = true
    tags = {
            Name = "${format("%s-db", var.name)}"
    }
}