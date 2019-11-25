#!/bin/sh

while true; do 
echo "\nWhat do you want to do? Please select number:
(1) Create or Delete keypair
(2) Create or Update or Delete stack
(3) Configure elastic ip 
(4) Configure security group
(5) Add or Delete cloudflare DNS records
(6) Exit script
"
read number

################################################################################################################################

if [ $number = "1" ]; then
#cd into your preferred directory and run the script

echo "\nWhat is the name of your key pair?"
read KeyPair

echo "\nWhat do you want to do with your key pair?
Type (1) to create
Type (2) to delete
"
read number_kp
if [ $number_kp = "1" ]; then
aws ec2 create-key-pair --key-name $KeyPair --query 'KeyMaterial' --output text > $KeyPair.pem
chmod 400 $KeyPair.pem
echo "Created '$KeyPair' keypair"
fi

if [ $number_kp = "2" ]; then
aws ec2 delete-key-pair --key-name $KeyPair
echo "Deleted '$KeyPair' keypair"
fi

echo "Finish"

fi

################################################################################################################################
if [ $number = "2" ]; then

#set -e tells bash, in a script, to exit whenever anything returns a non-zero return value.
set -e

#add the commands to download AWS CLI

echo "\nDo you want to create, update or delete stack?
'create' to create stack
'update' to update stack
'delete' to delete stack\n"
read deploytype
echo "you have chosen to $deploytype stack\n"

echo "Please enter stack name:"
read STACK_NAME
echo "Your stack name is $STACK_NAME\n"

#The WordPress database name
echo "Please enter DBName:"
read DBName
echo "Your DBName is $DBName\n"

#The WordPress database admin account username
echo "Please enter DBUser:"
read DBUser
echo "Your DBUser is $DBUser\n"

## Password
# "-p" means user is prompted to enter DB password and the output is stored in the "DBPassword" variable
# "-s" means the password is typed next to "Enter DB Password: " instead of below it

#The WordPress database admin account password
read -s -p "Enter DB Password: " DBPassword \n
echo -e "\nYour DB Password is: " $DBPassword "\n"

#MySQL root password
read -s -p "Enter DB Root Password: " DBRootPassword \n
echo -e "\nYour DB Root Password is: " $DBRootPassword "\n"

#The WordPress database admin account username
echo "Please enter the following InstanceType:
t1.micro
t2.nano
t2.micro
t2.small
t2.medium
t2.large\n"
read InstanceType
echo "You have chosen $InstanceType\n"

#Name of an existing EC2 KeyPair to enable SSH access to the instances
echo "Please enter KeyName:"
read KeyName
echo "Your KeyName is $KeyName\n"

#Name of tag for instance
echo "Please enter a tag name for the instance:"
read ROLE
echo "Your instance name is $ROLE\n"


echo "These are your parameters:
Stack Name    : $STACK_NAME
DBName        : $DBName
DBUser        : $DBUser
DBPassword    : $DBPassword
DBRootPassword: $DBRootPassword
InstanceType  : $InstanceType
KeyName       : $KeyName
Tag Name      : $ROLE
Template File : $TEMPLATE_FILE\n
"
#Have to put below because the the value is input at the start. If put at the start, the values are empty.
STACK_PARAMS="ParameterKey=DBName,ParameterValue=$DBName ParameterKey=DBUser,ParameterValue=$DBUser ParameterKey=DBPassword,ParameterValue=$DBPassword ParameterKey=DBRootPassword,ParameterValue=$DBRootPassword ParameterKey=InstanceType,ParameterValue=$InstanceType ParameterKey=KeyName,ParameterValue=$KeyName"
STACK_TAGS="Key=Name,Value=$ROLE"


### creating, deploying or destroying
# blog.yml changed to temp_yml that has the user_input domain name

## validating stack
echo "### Validating -> temp_blog.yml"
aws cloudformation validate-template --template-body file://temp_blog.yml

## create stack
echo "### Creating ${STACK_NAME}"
if [ $deploytype = "create" ]; then
aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://temp_blog.yml --parameters ${STACK_PARAMS} --tags ${STACK_TAGS} --capabilities CAPABILITY_IAM
echo "Created '${STACK_NAME}' stack"
fi

## update stack
echo "### Updating ${STACK_NAME}"
if [ $deploytype = "update" ]; then
aws cloudformation update-stack --stack-name ${STACK_NAME} --template-body file://temp_blog.yml --parameters ${STACK_PARAMS} --tags ${STACK_TAGS} --capabilities CAPABILITY_IAM
echo "Updated '${STACK_NAME}' stack"
fi

## delete stack
echo "### Deleting ${STACK_NAME}"
if [ $deploytype = "delete" ]; then
aws cloudformation delete-stack --stack-name ${STACK_NAME}
echo "Deleted '${STACK_NAME}' stack"
fi

echo "Finish"

fi


################################################################################################################################ 
while [ $number = "3" ]; do

echo "\nWhat do you want to do?
Type (1) to allocate a new address
Type (2) to associate address
Type (3) to dissociate address
Type (4) to release address
Type (5) to exit

"
read address

if [ $address = "1" ]; then
#Creates a new elastic ip address
aws ec2 allocate-address --domain vpc
echo "\nAllocated a new address\n"
echo "\nRemember to save the allocation ID and public ip address\n"
fi

if [ $address = "2" ]; then
echo "What is the allocation ID of the new allocated elastic ip? Copy and paste 'AllocationId'"
read AllocationId

echo "What is the tag name of the instance?"
read InstanceName

aws ec2 describe-instances --filters "Name=tag:Name,Values=$InstanceName"

echo "What is the Instance ID? Copy and Paste 'InstanceId'"
read InstanceId

echo "What do you want to tag the elastic ip as?"
read elastic_ip_tag

#create tag name for elastic IP
aws ec2 create-tags --resources $AllocationId --tags Key=Name,Value=$elastic_ip_tag

#associate the IP address of the newly created instance to the elastic IP
aws ec2 associate-address --allocation-id $AllocationId --instance-id $InstanceId
echo "Associate the elastic ip to the instance\n"
fi

if [ $address = "3" ]; then
echo "What is the allocation ID of the new allocated elastic ip? Copy and paste 'AllocationId'"
read AllocationId

aws ec2 disassociate-address --association-id $AllocationId
echo "Dissociate Address\n"
fi

if [ $address = "4" ]; then
echo "What is the allocation ID of the new allocated elastic ip? Copy and paste 'AllocationId'"
read AllocationId

aws ec2 release-address --allocation-id $AllocationId
echo "Release Address \n"
fi

if [ $address = "5" ]; then
break
fi

done

################################################################################################################################
while [ $number = "4" ]; do

echo "\nWhat do you want to do?
Type (1) to authorize HTTPS for both IPV4 and IPv6 address
Type (2) to authorise HTTP for IPV6 Address
Type (3) to revoke HTTPS for both IPV4 and IPv6 address
Type (4) to revoke SSH
Type (5) to exit"

read authorize

if [ $authorize = "1" ]; then

echo "\nWhat is the tag name of the instance?\n"
read InstanceName

aws ec2 describe-instances --filters "Name=tag:Name,Values=$InstanceName"

echo "\nWhat is the Security GroupID? Copy and Paste 'GroupID' under 'SecurityGroups'\n"
read GroupID

#To allow https
aws ec2 authorize-security-group-ingress --group-id $GroupID --protocol tcp --port 443 --cidr 0.0.0.0/0

#To allow IPV6 address for HTTPS
aws ec2 authorize-security-group-ingress --group-id $GroupID --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges='[{CidrIpv6=::/0}]'

echo "Added HTTPS for both IPV6 and IPV4 address"

fi

if [ $authorize = "2" ]; then

echo "\nWhat is the tag name of the instance?\n"
read InstanceName

aws ec2 describe-instances --filters "Name=tag:Name,Values=$InstanceName"

echo "\nWhat is the Security GroupID? Copy and Paste 'GroupID' under 'SecurityGroups'\n"
read GroupID

#To allow IPV6 address for HTTP
aws ec2 authorize-security-group-ingress --group-id $GroupID --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges='[{CidrIpv6=::/0}]'
echo "Added HTTP for IPV6 Address"
fi

if [ $authorize = "3" ]; then

echo "\nWhat is the tag name of the instance?\n"
read InstanceName

aws ec2 describe-instances --filters "Name=tag:Name,Values=$InstanceName"

echo "\nWhat is the Security GroupID? Copy and Paste 'GroupID' under 'SecurityGroups'\n"
read GroupID

aws ec2 revoke-security-group-ingress --group-id $GroupID --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 revoke-security-group-ingress --group-id $GroupID --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges='[{CidrIpv6=::/0}]'
echo "Revoked HTTPS"
fi

if [ $authorize = "4" ]; then
echo "\nWhat is the tag name of the instance?\n"
read InstanceName

aws ec2 describe-instances --filters "Name=tag:Name,Values=$InstanceName"

echo "\nWhat is the Security GroupID? Copy and Paste 'GroupID' under 'SecurityGroups'\n"
read GroupID

aws ec2 revoke-security-group-ingress --group-id $GroupID --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "Revoked SSH"
fi


if [ $authorize = "5" ]; then
break
fi

done


################################################################################################################################
if [ $number = "5" ]; then

# the POST API is from PALO IT cloudflare account under "Create DNS record"
# Use the authentication bearer because 1 api token is created to just create DNS record
# for name under "--data", put domain name, ttl set as 1 for automatic and content is the IP address
# ttl must be "ttl":1, integer and not a string like "1"
# Can edit proxy to false or true, true --> have proxy and false --> no proxy

#IMPORTANT --> take note of the ID, not the Zone_ID, when you get the output of this script, so as to delete the DNS record later
echo "\nDo you want to create or delete DNS record?
'create' to create record
'delete' to delete record"
read deployment

if [ $deployment = "create" ]; then
echo "What do you want your domain name to be?"
read name

#changes the domain name and takes the whole output and prints the output to a new file. This file will be used in creating the stack
sed -e "s/@@DOMAIN@@/$name/g" blog.yml > temp_blog.yml

echo "What is your IP address?"
read IP

echo "Do you want it to be proxied? Type 'true' or 'false'"
read proxy

echo "\nPlease save your 'id' number\n"

# '"\"$name\""' --> literal meaning for "name", the inner double quote is to quote the user input, 
# the backslash is to make it literal, 
# the outer double quote is to pass the variable as a string to take in the user input    
# '"$proxy"' --> proxy
 
curl -X POST "https://api.cloudflare.com/client/v4/zones/368ad69ff232d69a91f6e3e9b63192b2/dns_records" \
     -H "Authorization: Bearer ZoxcyTtiTxRxzt2aMsqeDmb5zptKSSM2bzLfWy3h" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":'"\"$name\""',"content":'"\"$IP\""',"ttl":1,"proxied": '"$proxy"'}'
echo "Created Domain Name"
fi

if [ $deployment = "delete" ]; then
# The API command is the one from the PALO IT cloudflare account under Delete DNS record
# The identifier behind is the ID you save when you get the output after you run the create_DNS_cloudfare.sh
# Use the authentication bearer because 1 api token is created to just create DNS record
# The identifier is "fe799caa3abd03617a6f77199fc2256e" in this example

echo "What is the id of the domain name?"
read DomainName

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/368ad69ff232d69a91f6e3e9b63192b2/dns_records/$DomainName" \
     -H "Authorization: Bearer ZoxcyTtiTxRxzt2aMsqeDmb5zptKSSM2bzLfWy3h" \
     -H "Content-Type: application/json"
echo "Deleted Domain Name"
fi

echo "Finish"

fi


################################################################################################################################
if [ $number = "6" ]; then
break
fi
################################################################################################################################
done