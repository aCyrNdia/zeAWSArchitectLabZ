# AWS Architect LabZ
... so I am Cyrille N'Dia, certified AWS Solution Architect and Terraform Associate.
I've done this (little) Git Repo to expose what I've learnt when preparing for my AWS certification exam... and after with my researches and LabZ.
Through these LabZ, I use all the tools that I've learnt... I'll do my best to explain the architectures for what I plan to deploy. And the next step would be to write Terraform Codes based on these architectures.

Hope YOU will enjoy what you'll see.

---
## Lab01 - AWS Config for S3
#### 1. We launch an S3 bucket - This one is for testing our rule.
- Here we've chosen to launch a bucket, but we could have launched any AWS service

#### 2. AWS Config Recorder
- To launch or create a config rule, we need a space where to declare the rules
- This space is called Recorder and we can only have ONE recorder by region
- We then launch a recorder

#### 3. AWS Config rules
- We write rule based on vulnerability we need to correct
- A single rule can only match a single vulnerability

#### 4. Remediation process
- The remediation process is used and launched everytime the rule match a vulnerability

---
## Lab02 - Autoscaling of instances behind a Load Balancer
### I. The Application Load Balancer
#### 1. Target Group
- A target group is a group of instances that an ELB use to balance loads
- All ELB configuration require a target group
- We then create a target group of instances

#### 2. Instance Type Template
- A target group must contain instances
- So we create instances that we want our target to use for load balancing

#### 3. Instance match Target
- We attach our instances to the target group
- We use only one attachment for only one instance
- So based on the number of instances we need, we used the same number of attachments

#### 4. Application Load Balancer
- After all, we then create our ALB
- We match the ALB with the target group that we created

### II. The Auto Scaling Group

#### 5. Launch Template/Launch Configuration
- A Launch Template/Configuration is a model of instances we want to be created by our scaling activities
- We require a template for a scaling group to be set

#### 6. Autoscaling Group
- We configure our auto scaling group based on the launch template/configuration
- The auto scaling group will be prompted whenever a threshold is matched
- We can auto scale based on different threshold

#### 7. Auto Scaling Attachement
- After configuring the auto scaling group, we then attach it to an ELB
- The link is made on the target group

---
## Lab03 - Simple VPC to launch our resources
#### 1. Create an empty VPC
#### 2. The Internet Gateway
#### 3. The subnets and their CIDR
#### 4. Route to the Internet
#### 5. Security Groups

---
## Lab04 - S3 Bucket with Policy and SSE-KMS encryption
#### 1. Create SSE-KMS key
#### 2. Create The bucket
