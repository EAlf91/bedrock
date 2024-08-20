# setup infra
 - VPC
    - public subnet, 
        - EC2 bastion host running ssm
    - 2 private subnets in different AZs
        - aurora serverless
    
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
https://tecadmin.net/install-python-3-8-amazon-linux/
https://www.python.org/downloads/release/python-3125/

pip install onnxruntime-gpu -i https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/ -qq

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
