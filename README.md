# wordpress-blog
Palo IT Blog --> b.paloitcloud.com.sg

# Steps to migrate WordPress blog to AWS 

# MANUAL 
(Log into AWS (Amazon Web Service) console)
1. Ensure region is Singapore at the top right hand of the console
2. Create a key pair to ssh into the instance.
3. Go to “Key Pairs” under “Network and Security” to create the keypair.
4. Go to CloudFormation and create a stack using the template in this folder  
5. In the “blog.yml” file, remember to manually change the “–d testblog2.paloitcloud.com.sg” to “-d (domain name created). The default WordPress template does not work as WordPress 5.2.2 requires php 5 and above and the default one installs a version that is too low --> users need not be worried as the "blog.yml" file has already solved this issue.
6. Set password for parameters and choose “large” instance.  
7. Once the stack creates an instance, go to “Elastic IPs” under “Network and Security” --> allocate a new address and associate the new elastic IP to the new instance. This is to prevent the IP address of the instance to keep changing. 
8. Go to “Security Groups” under “Network and Security” and click on the newly created instance --> click on the inbound tab below and click the “Edit” button --> add HTTPS and HTTP (both need 0.0.0.0/0 and ::/0) 
9. In the “blog.yml” file, remember to manually change the “–d testblog2.paloitcloud.com.sg” to “-d (domain name created)” --> the domain name should be created after running option (5) 
10. Once you run the template, enter elastic ip address with https. E.g. https://(elastic ip) 
11. Go into settings in wordpress and under website url and site url --> set it to domain name with “https” and no need “/wordpress”. Once the URL is set, you should refresh the browser and enter the URL you set in the settings inside wordpress.
12. SSH into the instance and check “/etc/httpd/conf/httpd.conf”--> “AllowOverride All” under <Directory “/var/www/html”> -->  this allows wordpress to access the .htaccess file 

Check if .htaccess is configured properly --> https://stackoverflow.com/questions/19400749/wordpress-permalinks-not-working-htaccess-seems-ok-but-getting-404-error-on-pa 

Also check if virtual host port 80 is configured --> https://community.letsencrypt.org/t/please-add-a-virtual-host-for-port-80/75818/3 --> DocumentRoot should be /var/www/html/wordpress and ServerName should be “name of website, e.g b.paloitcloud.com.sg” 


To increase the file upload size for a post in wordpress, ssh into instance and configure the .htaccess file in wordpress.
- cd /var/www/html/wordpress
- ls -lart
- sudo vim .htaccess

Add the two codes below between "# BEGIN WordPress" and "# END WordPress":

php_value upload_max_filesize 5000M

php_value post_max_size 5000M

To increase APACHE server timeout so as to upload larger file (default is about 20 seconds)
Website for help --> https://community.bitnami.com/t/wordpress-uploads-time-out-after-about-25-seconds-e-g-theme-file-upload/66741/9
Apache time out --> https://httpd.apache.org/docs/2.4/mod/mod_reqtimeout.html
- cd /etc/httpd/conf
- vim httpd.conf
- Add:
"<IfModule reqtimeout_module>
  RequestReadTimeout header=20-40,MinRate=500 body=20,MinRate=500
</IfModule>" --> view in raw format for README.md
- service httpd restart

To ensure that that wordpress do not change the settings after update, set .htaccess to mode 444, 440 or 400 whenever needed, meaning only readable. Set .htaccess to writeable only when there is a need to change existing configuration, if not, always in only readable mode.

For more details: https://perishablepress.com/stop-wordpress-htaccess/

 
# Importing content into the wordpress 
1. When wanting to import content, to go to plugin archive wordpress and download all-in-one wp migration 6.77 and increase the import file size  
2. To increase import size, go to “editor” under “plugins” and select all-in-one wp migration --> select “constants.php” --> under max file size, change it to “define( 'AI1WM_MAX_FILE_SIZE', 4294967296 * 10 );” 
3. Ensure the google cloud api credentials are set to the correct domain name 
4. Go to console and select PALO IT SG BLOG on top left 
5. Slide mouse to the left and select APIs & Services and choose credentials 
6. Click on web client and check if domain name is correct 
7. Click on OAuth Consent Screen and check if domain name is correct 

# Error Checking
- When making changes to cloudformation template 
- When using stack template, check “cat /var/log/cfn-init.log” to see any errors 
- Common error is when the directory of letsencrypt is created, the 2nd time the template runs, it will throw an error that the directory is already created and the whole process will stop. 
- Comment out the git clone for letsencrypt command in the template when doing testing so the error will not throw out 
- Also reboot the instance for any updates 
- For letsencrypt-auto help to edit the CloudFormation template for letsencrypt 
https://gist.github.com/ebekker/abd89a833c050669cd5a 
 
# Running of create_blog.sh 
- Preferably on Mac Book
- Download this folder onto your localhost and save it as any name you want

Run the script with "./create_blog.sh" 

Step 1: Run option (1) to create keypair to communicate with the instance. 

Step 2: Run option (3) then option (1) to allocate the elastic IP address. Remember to save the allocation ID and Public IP address to use in option (5) in the next step. After that, run option (5) to exit to the main menu.  

Step 3: Run option (5) and type in “create” to create a new DNS record. Type your preferred sub-domain name without “.paloitcloud.com.sg”. For example, enter “blog” instead of “blog.paloitcloud.com.sg” and the Public IP address as stated in “Step 2”. For proxied, choose ‘false’ unless as needed to be true. Save your DNS id number. 

Step 4: Run option (2) to create stack. Choose “t2.large” for instance size unless specified to use smaller instance by tech lead. When entering KeyName, there is no need to add in the file extension name. For example, enter “keypair” instead of “keypair.pem”. Wait for about 2 – 3 minutes to create the instance. 

Step 5: Run option (3) and then option (2) to associate the created instance with the elastic IP address. Copy and paste the allocation id as saved in “Step 2”. Run option (5) to exit. 

Step 6: Run option (4). Authorized HTTP and HTTPS for both IPV6 and IPV4. The SSH and HTTP for IPV4 is already set up when the instance is created. 
 
## Once the script is run, do step 10 and step 11 under “MANUAL” 

 
------------------------------------------------------------------------------------------------------------------------------ 
 
# Redirecting of blog.paloitcloud.com.sg to b.paloitcloud.com.sg

- Redirect of blog using cloudflare using "Page Rules"
- blog.paloitcloud.com.sg must be proxied but not b.paloitcloud.com.sg
- blog.paloitcloud.com.sg IP address is using the proxied IP address to the internal server

# Checking storage space of ec2 instance for github

ssh into the instance and key in this command "df -hT /dev/xvda1"

------------------------------------------------------------------------------------------------------------------------------ 


The orginal_blog.yml on creates a wordpress blog with no SSL encryption.

The blog.yml is the final edit of the creation of wordpress blog with SSL encryption with auto renewal of the cert.

When the "blog.yml" is renamed, remember to change the name of "blog.yml" to whatever you have renamed the yaml file to be in  line 322, "sed -e "s/@@DOMAIN@@/$name/g" blog.yml > temp_blog.yml" in the create_blog.sh.

------------------------------------------------------------------------------------------------------------------------------

# Backing up of wordpress blog (Automated)

- Go to AWS backup on the AWS console
- Create a backup vault to store all the snapshot (Only need to set the vault name and the rest keep as default)
- Create a backup plan by building a new plan (name the backup plan, set frequency to weekly and choose monday, choose the newly set up backup vault and the rest keep as default)
- Go to your backup plan and click assign resources
- Name your "Resource assignment name", choose default role, change "tag" to Resource ID under "Assign Resource"
- Choose EBS and then select the volume you created when you created the wordpress (this can be found under the description box, under "root device". Click that link and copy that volume ID)
- After that, click "assign resource"

------------------------------------------------------------------------------------------------------------------------------

# Backing up of wordpress blog (Manual)
- Click EC2 in AWS
- Go to "volume" under EBS "Elastic Block Store"
- Find the volume you attach the instance to
- Click on that volume and then click "Actions" then select "Create Snapshot"
- Fill in the information (Description and, Name and Tag) then click create
- Go to "volume" under EBS "Elastic Block Store" and check the snapshot

------------------------------------------------------------------------------------------------------------------------------

# Increase volume for instance

- Click EC2 in AWS
- Go to "volume" under EBS "Elastic Block Store"
- Find the volume you attach the instance to
- Click on that volume and then click "Actions" then select "Modify Volume"
- Increase size to what you need. In this case (100gb)
- Click modify and then wait for about 10 - 15 mins
- Reboot the instance then ssh into the instance to check the storage if it has incresaed (command to check: "df -hT /dev/xvda1")

------------------------------------------------------------------------------------------------------------------------------

# Errors faced
- The site is experiencing technical difficulties. Please check your site admin email inbox for instructions. 
- Fatal error: Allowed memory size of 41943040 bytes exhausted (tried to allocate 32768 bytes)

## Solutions
- Increased the memory limit, post max size and upload max filesize for wordpress
- vim /etc/php.ini
- "/memory_limit" --> increase to 12000M
- "/post_max_size" --> increase to 11000M
- "/upload_max_filesize" --> increase to 10000M
 
 
 
