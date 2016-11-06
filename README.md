# Automatic Web Root Generator
A simple Bash script for creating a standard structure for all websites. Very usefull if are going to manage a webserver without Cpanel or similar software.

### How to install
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

##### Screenshots
![sc1](https://cloud.githubusercontent.com/assets/5001801/20036465/556106c6-a409-11e6-8a27-fc72486f63c6.PNG)