resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
    Name = "Default_VPC"
    }
  }

  # Internet Gateway for internet Access
  resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
  }

  # Grant the VPC internet access on its main route table
  resource "aws_route" "internet_access" {
    vpc_id = "${aws_vpc.default.id}"
    route_table_id         = "${aws_vpc.default.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.default.id}"
  }

  # Create a subnet to launch our instances into
  resource "aws_subnet" "subnet1" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.0.0/24"
    map_public_ip_on_launch = true
  }

  # Create a subnet to launch RDS Instance
  resource "aws_subnet" "subnet2" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
  }

  resource "aws_route_table_association" "a" {
    subnet_id      = "${aws_subnet.subnet1.id}"
    route_table_id = "${aws_vpc.default.main_route_table_id}"
  }

  resource "aws_route_table_association" "b" {
    subnet_id      = "${aws_subnet.subnet2.id}"
    route_table_id = "${aws_vpc.default.main_route_table_id}"
  }

  resource "aws_db_subnet_group" "test_rds_sng" {
    name       = "rds_subnetgroup"
    subnet_ids = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]

    tags {
      Name = "test_rds_sng"
    }
  }

  # A security group for the ELB so it is accessible via the web
  resource "aws_security_group" "elb" {
    name        = "terraform_example_elb"
    description = "Used in the terraform"
    vpc_id      = "${aws_vpc.default.id}"

    # HTTP access from anywhere
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # outbound internet access
    egress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_elb" "web" {
    name = "Debian-Instance"

    subnets         = ["${aws_subnet.subnet1.id}"]
    security_groups = ["${aws_security_group.elb.id}"]

        depends_on = ["data.aws_instance.debian"]
    instances =  "${data.aws_instances.Debians.ids}"


    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      target = "HTTP:80/"
      interval = 30
    }
  }

  data "aws_instances" "Debian_Instance" {

    instance_tags = {
      Name = "Debian_Instance_Nginx"
    }


  resource "aws_elb_attachment" "web" {
  	count = "${var.instance_count}"
  	elb      = "${aws_elb.web.id}"
  	instance = "${element(aws_instance.Debian_.*, count.index)}"
  }

  resource "aws_instance" "Debian_Instance_Nginx" {

    count         = "${var.instance_count}"
    ami           = "${lookup(var.ami_id,var.aws_region)}"
    instance_type = "${var.instance_type}"
    availability_zone = "${var.aws_region}+a"
    subnet_id  = "${aws_subnet.subnet1.id}"

    tags = {
       Name = "${var.name}"
    }

    vpc_security_group_ids = [
      "${aws_security_group.http-group.id}",
      "${aws_security_group.https-group.id}",
      "${aws_security_group.ssh-group.id}",
      "${aws_security_group.all-outbound-traffic.id}",
    ]


    user_data = "${file("install_debian_nginx.sh")}"

    #provisioner "remote-exec" {
    #inline = [
    #  "sudo apt-get -y update",
    #  "sudo apt-get -y install nginx",
    #  "sudo service nginx start",
    #]
  #}

    }

    data "aws_instance" "debian" {

      count  = "${var.instance_count}"
      instance_id = "${aws_instance.debian[count.index].id}"

    }

  resource "aws_security_group" "https-group" {
    name = "https-access-group"
    description = "Allow traffic on port 443 (HTTPS)"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "HTTPS Inbound Traffic Security Group"
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }


  resource "aws_security_group" "http-group" {
    name = "http-access-group"
    description = "Allow traffic on port 80 (HTTP)"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "HTTP Inbound Traffic Security Group"
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }

  resource "aws_security_group" "all-outbound-traffic" {
    name = "all-outbound-traffic-group"
    description = "Allow traffic to leave the AWS instance"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "Outbound Traffic Security Group"
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }

  resource "aws_security_group" "ssh-group" {
    name = "ssh-access-group"
    description = "Allow traffic to port 22 (SSH)"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "SSH Access Security Group"
    }

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }

  # Security group resources
#
resource "aws_security_group" "postgresql" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name        = "sgDatabaseServer"
    },
    var.tags
  )
}

#
# RDS resources
#
resource "aws_db_instance" "postgresql" {
  allocated_storage               = var.allocated_storage
  engine                          = "postgres"
  engine_version                  = var.engine_version
  identifier                      = var.database_identifier
  snapshot_identifier             = var.snapshot_identifier
  instance_class                  = var.instance_type
  storage_type                    = var.storage_type
  iops                            = var.iops
  name                            = var.database_name
  password                        = var.database_password
  username                        = var.database_username
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  maintenance_window              = var.maintenance_window
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  final_snapshot_identifier       = var.final_snapshot_identifier
  skip_final_snapshot             = var.skip_final_snapshot
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  multi_az                        = var.multi_availability_zone
  port                            = var.database_port
  vpc_security_group_ids          = "${aws_security_group.postgresql.id}"
  storage_encrypted               = var.storage_encrypted
  deletion_protection             = var.deletion_protection

}
