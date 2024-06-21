# packer-build

Windows 2012 & 2016 & 2019
Amazon Linux 2 LTS & RHEL 7.6

To do :

- Readme / solution overview
- I suggest to implement AMI encryption by default
- Multi region deploy
- schedule release
- implement approval process
- saparte IAM role for golden-images
- IAM restriction on each of the accounts


CMK created on tooliing account: Administrators, Users able to decrypt, shared accross AWS accounts


target : Users, groups, roles with IAm policy attached can decrypt KNMs from Tooling account = lunch Ec2 instance usinig encrypted AMis!

"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:DescribeKey",
                "kms:ReEncrypt*",
                "kms:CreateGrant",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:<111111111111>:key/<key-id of cmkSource>"
            ]                                                    
        }
    ]
}"


IAM policy should also define conditons ie. if TAG or owner ID = Tooling account
