# setup infra
You need to have access to an AWS account with proper permissions to run this.
The way I set it up was creating a new AWS account (you need a credit card for this)

The Infra consists of the following:

 - VPC
    - public subnet, 
        - EC2 bastion host running ssm
    - 2 private subnets in different AZs
        - aurora serverless
    
Once you set it up you can run the terraform deployment:

> sh ./ci/deploy-tf.sh infra

# activate foundational models

For this tests I activated:  
- Claude V2

# open connection for rds
aws ssm start-session \
    --region us-east-1 \
    --target i-09f44e6bfed057306 \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters host="bedrock.cluster-c1ee2e0wq4md.us-east-1.rds.amazonaws.com",portNumber="5432",localPortNumber="5000"

# EC2 GPU

# prepare python
sudo apt-get update
sudo apt install python3.11
sudo apt-get install python3.11-venv
sudo apt-get install python3.11-dev

mkdir ./venvs
python3.11 -m venv ./venvs/bedrock
source ./venvs/bedrock/bin/activate

pip install fastembed

pip install onnxruntime-gpu==1.17.*

sudo apt-get install libcudnn8

# upload files
scp -i gpu.pem ./hp_all.json ubuntu@ec2-34-204-193-210.compute-1.amazonaws.com:./hp_all.json
scp -i gpu.pem ./*.py ubuntu@ec2-34-204-193-210.compute-1.amazonaws.com:./


source venvs/bedrock/bin/activate
python main.py 1 10
# download files
scp -i gpu.pem -r ubuntu@ec2-34-204-193-210.compute-1.amazonaws.com:./output1.csv ./
