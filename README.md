# Automatic Web Root Generator
A simple Bash script for creating a standard structure for all websites. Very usefull if are going to manage a webserver without Cpanel or similar software.

It creates a new folder in /var/www/SITENAME/public_html (or wherever you want, just edit the configuration file), with a user assigned (as home) and a log directory inside it (with all logs symlinked to /var/log folder).
It also generates the virtual host file for apache and reload the apache service.

At the end of the process creates an index.html page, based on the configuration template files.

### Instructions
##### Basic installation

    git clone https://github.com/CRYX2/Automatic-web-root-generator.git awrg 
    sudo mv awrg /etc/awrg
    sudo chmod +x /etc/awrg/add_vhost.sh
    sudo ln -s /etc/awrg/add_vhost.sh /usr/local/sbin/add_vhost

##### Edit configuration

    sudo cp /etc/awrg/awrg.cnf.DEFAULT /etc/awrg/awrg.cnf
    sudo vi /etc/awrg/awrg.cnf

Check all settings for reflecting your configuration

##### How to use
`sudo add_vhost`

Enjoy :)

PS. Actually it works only with bash, NOT with fish or zsh

##### Screenshots
![sc1](https://cloud.githubusercontent.com/assets/5001801/20036465/556106c6-a409-11e6-8a27-fc72486f63c6.PNG)

![sc1](https://cloud.githubusercontent.com/assets/5001801/20036539/e8f956c6-a40a-11e6-91b5-bf90937dac01.PNG)

![sc1](https://cloud.githubusercontent.com/assets/5001801/20036538/e8e47b70-a40a-11e6-8a91-b8eb5528d29d.PNG)
