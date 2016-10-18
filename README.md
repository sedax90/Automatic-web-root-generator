# Automatic Web Root Generator
A simple Bash script for creating a standard structure for all websites. Very usefull if are going to manage a webserver without Cpanel or similar software.

#### How to install
---
##### Install
 1. git clone https://github.com/CRYX2/Automatic-web-root-generator.git awrg 
 2. sudo mv awrg /etc/awrg
 3. sudo chmod +x /etc/awrg/add_vhost.sh
 4. sudo ln -s /etc/awrg/add_vhost.sh /usr/local/sbin/add_vhost

##### Edit configuration
1. sudo cp /etc/awrg/awrg.cnf.DEFAULT /etc/awrg/awr.cnf
2. sudo vi /etc/awrg/awrg.cnf
3. Check all settings for reflecting your configuration

##### How to use
`sudo add_vhost`

##### Screenshots
![sc1](https://cloud.githubusercontent.com/assets/5001801/19471000/d61ca4d8-9521-11e6-8006-a0f3867be647.jpg)