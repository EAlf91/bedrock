cd $1
terraform fmt --recursive
terraform init
terraform plan
terraform apply