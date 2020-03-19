variable "aws_region" {
  description = "AWS region N.Virginia"
  default = "us-east-1"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default = "Debian_Instance_Nginx"
}

variable "aws_vpc" {
  description = "VPC created in the other module"
  default = ""
}

variable "aws_subnet" {
  description = "subnet for instances"
  default = ""
}

variable "instance_count" {
  default = "1"
}

################

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "MyKeyPair"
}


# Ubuntu 9 AMI (x64)
variable "ami_id" {   # "aws_amis" {

    type = "map"

   default = {
     "us-east-1" = "ami-0ed2d2283aa1466df"
     "us-east-2" = "ami-07a0560634acb945f"
     "us-west-1" = "ami-0ff3a5bef845ec04f"
     "us-west-2" = "ami-0fdf2e9fd534f1b2f"
   }
  }

variable "public_key_path" {
 default = "/Users/vijay0690/.ssh/id_rsa" #.pub"
}


variable "allocated_storage" {
  default     = 32
  type        = number
  description = "Storage allocated to database instance"
}

variable "engine_version" {
  default     = "11.5"
  type        = string
  description = "Database engine version"
}

variable "instance_type_db" {
  default     = "db.t3.micro"
  type        = string
  description = "Instance type for database instance"
}

variable "storage_type" {
  default     = "gp2"
  type        = string
  description = "Type of underlying storage for database"
}

variable "iops" {
  default     = 0
  type        = number
  description = "The amount of provisioned IOPS"
}

variable "database_identifier" {
  type        = string
  description = "Identifier for RDS instance"
}

variable "snapshot_identifier" {
  default     = ""
  type        = string
  description = "The name of the snapshot (if any) the database should be created from"
}

variable "database_name" {
  type        = string
  description = "Name of database inside storage engine"
}

variable "database_username" {
  type        = string
  description = "Name of user inside storage engine"
}

variable "database_password" {
  type        = string
  description = "Database password inside storage engine"
}

variable "database_port" {
  default     = 5432
  type        = number
  description = "Port on which database will accept connections"
}

variable "backup_retention_period" {
  default     = 30
  type        = number
  description = "Number of days to keep database backups"
}

variable "backup_window" {
  # 12:00AM-12:30AM ET
  default     = "04:00-04:30"
  type        = string
  description = "30 minute time window to reserve for backups"
}

variable "maintenance_window" {
  # SUN 12:30AM-01:30AM ET
  default     = "sun:04:30-sun:05:30"
  type        = string
  description = "60 minute time window to reserve for maintenance"
}

variable "auto_minor_version_upgrade" {
  default     = true
  type        = bool
  description = "Minor engine upgrades are applied automatically to the DB instance during the maintenance window"
}

variable "final_snapshot_identifier" {
  default     = "terraform-aws-postgresql-rds-snapshot"
  type        = string
  description = "Identifier for final snapshot if skip_final_snapshot is set to false"
}

variable "skip_final_snapshot" {
  default     = true
  type        = bool
  description = "Flag to enable or disable a snapshot if the database instance is terminated"
}

variable "copy_tags_to_snapshot" {
  default     = false
  type        = bool
  description = "Flag to enable or disable copying instance tags to the final snapshot"
}

variable "multi_availability_zone" {
  default     = false
  type        = bool
  description = "Flag to enable hot standby in another availability zone"
}

variable "storage_encrypted" {
  default     = false
  type        = bool
  description = "Flag to enable storage encryption"
}

variable "deletion_protection" {
  default     = false
  type        = bool
  description = "Flag to protect the database instance from deletion"
}

variable "subnet_group" {
  type        = string
  description = "Database subnet group"
}

variable "parameter_group" {
  default     = "default.postgres11"
  type        = string
  description = "Database engine parameter group"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the RDS resources"
}
