#Creates a new elastic ip address
aws ec2 allocate-address --domain vpc

echo "What is the allocation ID of elastic ip? Copy and paste 'AllocationId'"
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

echo "What is the Security GroupID? Copy and Paste 'GroupID' under 'SecurityGroups'"
read GroupID

echo "What is the vpcID? Copy and Paste 'VpcId' under 'Instances'"
read GroupID

#To allow https
aws ec2 authorize-security-group-ingress --group-id $GroupID --protocol tcp --port 443 --cidr 0.0.0.0/0

#To allow IPV6 address for HTTP
aws ec2 authorize-security-group-ingress --group-id $GroupID --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges='[{CidrIpv6=::/0}]'

#To allow IPV6 address for HTTPS
aws ec2 authorize-security-group-ingress --group-id $GroupID --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges='[{CidrIpv6=::/0}]'



