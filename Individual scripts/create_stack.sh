#!/bin/sh

#set -e tells bash, in a script, to exit whenever anything returns a non-zero return value.
set -e

#add the commands to download AWS CLI

echo "Do you want to create, update or delete stack?
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

#Name of CloudFormation Template
echo "Please enter name of CloudFormation Template:"
read TEMPLATE_FILE
echo -e "You have chosen $TEMPLATE_FILE\n"


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

## validating stack
echo "### Validating -> ${TEMPLATE_FILE}"
aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}

## create stack
echo "### Creating ${STACK_NAME}"
if [ $deploytype = "create" ]; then
aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://${TEMPLATE_FILE} --parameters ${STACK_PARAMS} --tags ${STACK_TAGS} --capabilities CAPABILITY_IAM
fi

## update stack
echo "### Updating ${STACK_NAME}"
if [ $deploytype = "update" ]; then
aws cloudformation update-stack --stack-name ${STACK_NAME} --template-body file://${TEMPLATE_FILE} --parameters ${STACK_PARAMS} --tags ${STACK_TAGS} --capabilities CAPABILITY_IAM
fi

## delete stack
echo "### Deleting ${STACK_NAME}"
if [ $deploytype = "delete" ]; then
aws cloudformation delete-stack --stack-name ${STACK_NAME}
fi