# setup infra
 - VPC
    - public subnet, 
        - EC2 bastion host running ssm
    - 2 private subnets
        - aurora serverless
    
# activate foundational models


# open connection for rds
aws ssm start-session \
    --region us-east-1 \
    --target i-09f44e6bfed057306 \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters host="bedrock.cluster-c1ee2e0wq4md.us-east-1.rds.amazonaws.com",portNumber="5432",localPortNumber="5000"

