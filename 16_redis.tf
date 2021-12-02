resource "aws_elasticache_subnet_group" "redis_subnet" {
    name       = "${var.name}-redis-subnet"
    subnet_ids = aws_subnet.was_subnet.*.id
}

resource "aws_elasticache_cluster" "redis" {
    cluster_id           = "${var.name}-redis"
    engine               = "redis"
    node_type            = "cache.t2.micro"
    num_cache_nodes      = 1                # 1이상
    subnet_group_name    = aws_elasticache_subnet_group.redis_subnet.name
    security_group_ids   = [aws_security_group.security_redis.id]
    # parameter_group_name = "default.redis3.2"  # default 파라미터 그룹:클러스터의 파라미터 그룹default.redis6.x (in-sync)
    # engine_version       = "3.2.10"            # default 엔진 버전 호환성:해당 노드에서 실행될 엔진의 버전 호환성6.2.5
    port                 = 6379
}

resource "aws_security_group" "security_redis" {
    name = "${format("%s-sg-redis", var.name)}"
    description = "security group for redis"
    vpc_id      = aws_vpc.vpc.id

    ingress = [
        {
            description      = ""
            from_port        = 6379
            to_port          = 6379
            protocol         = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            security_groups    = [aws_security_group.security_was.id]
            prefix_list_ids = []
            self = false
        }
    ]

    egress = [
        {
            description = ""
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            security_groups = []
            prefix_list_ids = []
            self = false
        }
    ]
    
    tags = {
        Name = "${format("%s-sg-redis", var.name)}"
    }
}