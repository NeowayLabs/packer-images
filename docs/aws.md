### Amazon Web Services

### Export your credentials and configurations as environment variables

[Create an IAM User in Your AWS Account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html), get your [Access Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) and then export the credentials as a variable to use inside a container.

```bash
$ export AWS_ACCESS_KEY="YOUR_AWS_ACCESS_KEY"
$ export AWS_SECRET_KEY="YOUR_AWS_SECRET_KEY"
```
You also need configure your AWS VPC Region and [create or use an existent SSH Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to access the EC2 instances created. For local tests, create a randomic id and put as an environment variable on `TRAVIS_BUILD_ID` to identify the AMI.

```bash
$ export AWS_VPC_REGION=YOUR_AWS_VPC_REGION
$ export AWS_SSH_KEYNAME=YOUR_AWS_SSH_KEYNAME
$ export TRAVIS_BUILD_ID=ANY_RANDOMIC_ID
```

## Create the infrastructure

### Build AMI with Packer

```bash
$ make packer-build env=aws image=image-ubuntu
```

After this step, you will have an image listed on AMI Public Repository.

### Create EC2 instance using new AMI with Terraform

```bash
$ make terraform-init provider=aws env=images-tester
```
```bash
$ make terraform-apply provider=aws env=images-tester
```

## Destroy the infrastructure

```bash
$ make terraform-destroy provider=aws env=images-tester
```
