#!/bin/bash

. "${PWD}/awrg.cnf"

backtitle="Webroot generator - Created by Cristian Sedaboni"

checkIfWhiptailIsInstalled() {
	if [ $(dpkg-query -W -f='${Status}' whiptail 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
	  apt-get install whiptail;
	fi
}

# Create physically the web root folder
createWebRoot() {
	local directory="$web_root/$domain"

	if [ -d "$directory" ]; then
		echo "A directory for the domain $domain exists yet, please enter another domain"
	else
		mkdir $directory
	fi
}

inputDomain() {
	input=$(whiptail --backtitle "$backtitle" --inputbox \
	"Insert website main domain, without http and www (Ex. test.it)" 10 80 3>&1 1>&2 2>&3)
	exitstatus=$?

	if [ $exitstatus = 0 ]; then
	    domain=$input
	else
	    echo "User selected Cancel."
	    exit
	fi
}

inputUser() {
	input=$(whiptail --backtitle "$backtitle" --inputbox \
	"Insert the new user name" 10 80 "$username" 3>&1 1>&2 2>&3)
	exitstatus=$?

	if [ $exitstatus = 0 ]; then
	    username=$input
	else
	    echo "User selected Cancel."
	    exit
	fi
}

inputPassword() {
	input=$(whiptail --backtitle "$backtitle" --inputbox \
	"Change password (or use the generated below)" 10 80 "$password" 3>&1 1>&2 2>&3)
	exitstatus=$?

	if [ $exitstatus = 0 ]; then
	    password=$input
	else
	    echo "User selected Cancel."
	    exit
	fi
}

inputServerAlias() {
	input=$(whiptail --backtitle "$backtitle" --inputbox \
	"Add Server Alias separated by space (Ex. test.com www.test.com))" 10 80 "www.$domain" 3>&1 1>&2 2>&3)
	exitstatus=$?

	if [ $exitstatus = 0 ]; then
	    aliases=$input
	else
	    echo "User selected Cancel."
	    exit
	fi
}

generateUsername() {
	local original="$domain"
	username="${original/./_}"
}

generatePassword() {
	password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
}

createUser() {
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	useradd -m -p $pass $username -d "$web_root/$domain" -s /bin/bash
	[ $? -eq 0 ] && echo "" || echo "Failed to add a user!"
}

assignPermissionsToWebRoot() {
	chown $username:www-data $web_root/$domain -R
}

errorDialog() {
	whiptail --backtitle "$backtitle" --msgbox "$message" 10 80
}

checkIfUserExists() {
	ret=false
	getent passwd $username >/dev/null 2>&1 && ret=true
}

createPublicHtmlFolder(){
	local directory="$web_root/$domain/$public_folder"
	mkdir $directory
	chmod 775 $directory
}

createIndexHtml() {
	local directory="$web_root/$domain/$public_folder"
	touch "$directory/index.html"
	defaultValue="$(cat $indexSample)"
	echo $defaultValue >> "$directory/index.html"
}

assignVirtualHostFilename() {
	local original="$domain"
	virtualHostFilename="${original/./-}"
}

writeVirtualHost() {
	local vh="$sitesAvailable/$virtualHostFilename.conf"
	touch $vh
	if ! echo "
<VirtualHost *:$apache_port>
	ServerAdmin $email
	ServerName $domain
	ServerAlias $aliases
	DocumentRoot $web_root/$domain/$public_folder
	<Directory $web_root/$domain/$public_folder>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride all
		Require all granted
	</Directory>
	ErrorLog ${apache_log_dir}/${domain/./-}--error.log
	LogLevel error
	CustomLog ${apache_log_dir}/${domain/./-}--access.log combined
</VirtualHost>" >> $vh
	then
		echo -e $"There is an ERROR creating $domain file"
		exit;
	else
		echo -e $"\nNew Virtual Host Created\n"
	fi
}

enableApacheDomain() {
	### enable website
	a2ensite $virtualHostFilename

	### restart Apache
	/etc/init.d/apache2 reload
}

createLogFolder() {
	touch "${apache_log_dir}/${domain/./-}--access.log"
	touch "${apache_log_dir}/${domain/./-}--error.log"
}

addLogAliases() {
	local site_log_directory="$web_root/$domain/$log_folder"
	mkdir "${site_log_directory}"

	ln -s ${apache_log_dir}/${domain/./-}--access.log "${site_log_directory}/access.log"
	ln -s ${apache_log_dir}/${domain/./-}--error.log "${site_log_directory}/error.log"
}

createSuccessfullMessage() {
	whiptail --backtitle "$backtitle" --title "Successfull!" --msgbox "\
	Created directory web root at: $web_root/$domain
	Created new user with:
	Username: $username
	Password: $password" 10 80
}

# --- START ---

# permissions
if [ "$(whoami)" != "root" ]; then
	echo "Root privileges are required to run this, try running with sudo..."
	exit 2
fi

checkIfWhiptailIsInstalled

# assign domain
while [ -z "$domain" ] ; do
	inputDomain
done

# createWebRoot
generateUsername username

ret=false
checkIfUserExists
while [ "$ret" == "true" ]; do
	message="The user exists yet, please enter another username"
    errorDialog $message
    inputUser

    checkIfUserExists ret
done

generatePassword password
inputPassword
createUser
createLogFolder
createPublicHtmlFolder
createIndexHtml
assignPermissionsToWebRoot
assignVirtualHostFilename
inputServerAlias aliases
addLogAliases
writeVirtualHost
enableApacheDomain
createSuccessfullMessage

