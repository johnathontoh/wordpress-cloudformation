
# the POST API is from PALO IT cloudflare account under "Create DNS record"
# Use the authentication bearer because 1 api token is created to just create DNS record
# for name under "--data", put domain name, ttl set as 1 for automatic and content is the IP address
# ttl must be "ttl":1, integer and not a string like "1"
# Can edit proxy to false or true, true --> have proxy and false --> no proxy

#IMPORTANT --> take note of the ID, not the Zone_ID, when you get the output of this script, so as to delete the DNS record later
echo "Do you want to create or delete DNS record?
'create' to create record
'delete' to delete record"
read deployment

if [ $deployment = "create" ]; then
echo "What do you want your domanin name to be?"
read name

echo "What is your IP address?"
read IP

echo "Do you want it to be proxied? Type 'true' or 'false'"
read proxy

# '"\"$name\""' --> literal meaning for "name", the inner double quote is to quote the user input, 
# the backslash is to make it literal, 
# the outer double quote is to pass the variable as a string to take in the user input    
# '"$proxy"' --> proxy
 
curl -X POST "https://api.cloudflare.com/client/v4/zones/368ad69ff232d69a91f6e3e9b63192b2/dns_records" \
     -H "Authorization: Bearer ZoxcyTtiTxRxzt2aMsqeDmb5zptKSSM2bzLfWy3h" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":'"\"$name\""',"content":'"\"$IP\""',"ttl":1,"proxied": '"$proxy"'}'

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
fi