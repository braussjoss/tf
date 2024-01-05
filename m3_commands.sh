mkdir globo_web_app
cp ~/tf/main.tf  ~/tf/globo_web_app/main.tf
cd globo_web_app
terraform plan -out m3.tfplan
terraform apply "m3.tfplan"