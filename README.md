# devops/Terraform/AWS-Build
# ws-build-with-ALB-DDOS-Monitoring-failover.tf


- AWS Shield Protection is enabled for the application load balancer (web_alb) in the primary region (us-east-1) to protect against DDoS attacks.
- An AWS WAF (Web Application Firewall) Web ACL (web_waf_acl) is created with rules to protect against common web vulnerabilities such as SQL injection attacks.
- The Web ACL is associated with both the application load balancer (web_alb) in the primary region and the backup application load balancer (backup_web_alb) in the backup region to ensure consistent security policies across regions.

By integrating AWS Shield and AWS WAF, your infrastructure is better protected against DDoS attacks and common web vulnerabilities, enhancing the security posture of your web services deployed in AWS.


Workflow:
1. Primary Region (us-east-1):

    Auto Scaling Group (ASG) with instances deployed across multiple Availability Zones (AZs).
    Application Load Balancer (ALB) distributing traffic to instances in the ASG.
    Security Group for the instances.
    S3 Bucket for storing static assets.
    AWS Shield Protection enabled for the ALB.
    AWS WAF Web ACL associated with the ALB.

2. Backup Region (us-west-1 or your chosen region):

    Similar setup as the primary region:
        ASG with instances deployed across multiple AZs.
        ALB distributing traffic to instances in the ASG.
        Security Group for the instances.
        S3 Bucket for storing static assets.
    AWS Shield Protection is automatically provided by AWS for all resources in the region.
    AWS WAF Web ACL associated with the ALB.

3. DNS Routing:

    Route 53 or your DNS provider configured with a failover routing policy.
    Primary routing to the ALB in the primary region.
    Secondary routing to the ALB in the backup region with a lower priority or weight.

4. DDoS Protection and Security Threat Mitigation:

    Flow indicating traffic passing through AWS Shield and AWS WAF before reaching the ALB.
    Arrows representing traffic being inspected for DDoS attacks and common web vulnerabilities.


Detailed instructions:

1. Create an IAM User with Administrator Access
Go to the AWS Management Console.
Navigate to the IAM service.
Create a new IAM user with AdministratorAccess permission.

2. Configure AWS CLI (Command Line Interface)
Install the AWS CLI on your local machine if not already installed.
Configure the AWS CLI with the IAM user's credentials

    aws configure

3. Enter the IAM user's Access Key ID and Secret Access Key, along with preferred region and output format.

4. Install Terraform
Download and install Terraform on your local machine from Terraform's official website.

5. Create Terraform Configuration Files
Create a directory for your Terraform project.
Inside the directory, create a file named main.tf and copy the Terraform configuration provided earlier.
Optionally, create a file named variables.tf to define variables for your configuration.
Optionally, create a file named outputs.tf to define outputs for your configuration.