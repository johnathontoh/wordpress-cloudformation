#cd into your preferred directory and run the script

echo "What is the name of your key pair?"
read KeyPair

aws ec2 create-key-pair --key-name $KeyPair --query 'KeyMaterial' --output text > $KeyPair.pem