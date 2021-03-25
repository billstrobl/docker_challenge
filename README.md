# Docker Deployer

A set of Terraform modules used to pull Docker Containers from ECR and run them on EC2 instances. 
The backend module will create a new EC2 instance and all the required infrastructure to be able to
run a Docker Container and be accessible via HTTP and SSH. The Docker module will run the Docker container
on the target instance (via SSH) and creates a Docker Service to monitor heal from negative health checks.


## Usage Notes
If starting from scratch, run the Backend module first. Then run the Docker module.
If you simply want to run a container on an existing EC2 instance, run the Docker module with the correct vars.


## Development Notes
This project relies on a remote statefile. If you need to do some testing/exploring, comment out the S3 backend config
and run `terraform init` again. This will allow you to modify the infrastructure without effecting existing
environments. If you are doing this, please be aware of potential conflicts with existing infrastructure. 

The Docker module can be used locally safely by replacing "host" value in the provider stanza with `127.0.0.1`.

The remote statefile is stored in S3 in a bucket called "state-bucket" and uses a DynamoDB table called "state-locks"
to manage locking the statefile. These artifacts are created outside this project and MUST exist prior to running
these modules.


## Variables and Options
| Name  | Default Values | Description |
|-------|--------|----|
| region | `us-west-2` | The AWS region where the backend infrastructure will be created. |
| cidr   | `10.0.0.0/32` | The CIDR block used with the security group to open ports. |
| open_ports | `4567` | The list of ports that will be exposed on the EC2 instance. |
| instance_type | `t2.micro` | The instance type that will be created to host the Docker Container. |
| vpc_id | Must be provided | The ID of the VPC where the backend infrastructure will be created. |
| task_name   | Must be provided | The name of the application that will be deployed. |
| key_name  | Must be provided | The name of the key pair that will be associated with the new EC2 instance. |
| ecr_repo_name | Must be provided | The name of the Docker repo in ECR that hosts the Container. |
| username | Must be provided | The user that will be used to SSH to the remote instance and manage Docker. |
| target_ip | Must be provided | The IP of the target instance to run the desired Container. |
| docker_repo_url | Must be provided | The URL of the ECR repo hosting the desired Container. |
| image_name | Must be provided | The name of the image to use to build the desired Container. |


## Release Notes
| Date | Version | Notes |  
|---|---|---|
|25 March 2021|0.1|Initial version of Docker Deployer|
