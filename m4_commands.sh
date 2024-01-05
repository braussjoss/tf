#If we pass vars through command line
terraform plan -var=billing_code="MYBILLINGACCOUNT1234-1234-1234" -var=project="web-app" -out m4.tfplan

#
terraform plan -out m4.tfplan
terraform apply "m4.tfplan"

terraform show
terraform output

