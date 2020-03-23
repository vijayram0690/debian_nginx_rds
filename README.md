### Terraform Automation - HA contanerized nginx webserver setup and RDS Postgres cluster.

### Resources created by this template.
* This creates a new `VPC` in us-east-1 (default region) with 2 `public subnets`
* This also creates separate security_groups for `instances` and `ELB`. 
* nginx is installed with `user_data` script supplied to instance.
* We are also creating RDS Postgresql Instance

### Prerequisites 
* AWS Secret Access Key and Private Key Configuration
* Terraform Installed on your local workstation.

### Clone repository
```
$ git clone https://github.com/vijayram0690/debian_nginx_rds.git
cd debian_nginx_rds
```

## Setup 

### Initialize terraform
```
$ terraform init
```

### dry-run
```
$ terraform plan

When applying the plan, Variables has to be declared as of now for this repo variables has not been declared, left for default values. 
```
Post we declare the varaibles, If everything looks ok during `terraform plan` then apply real changes using `terraform apply`

### Apply terraform 
```
$ terraform apply
```

## Access
Once `terraform apply` is `successful`, you will see the `elb_dns_name` configured as a part of output. you can hit `elb_dns_name` in your browser and should see the sample response from nginx deployed or you can access `elb_dns_name` from CLI as well as given below.

`while true; do curl hiver-test-elb-********.us-east-1.elb.amazonaws.com; done`

