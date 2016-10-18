#!/bin/bash

source /etc/awrg/awrg.cnf

backtitle="Webroot generator v0.0.1 - Created by Cristian Sedaboni"

checkIfDialogIsInstalled() {
	if [ $(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
	  apt-get install dialog;
	fi
}

# Create physically the web root folder
createWebRoot() {
	local directory="$web_root/$domain"

	if [ -d "$directory" ]; then
		echo "A directory for the domain $domain exists yet, please enter another domain"
	else
		mkdir $directory
		echo "Created directory web root at: $web_root/$domain"
	fi
}

inputDomain() {
	dialog --backtitle "$backtitle" --inputbox \
	"Insert website main domain, without http and www (Ex. test.it)" 10 80 2> /tmp/inputbox.tmp.$$
	retval=$?
	input=`cat /tmp/inputbox.tmp.$$`
	rm -f /tmp/inputbox.tmp.$$

	case $retval in
		0) 
		  	domain="$input"
		  	;;
		1) 
			echo "Exiting..."
			exit
			;;
	esac
}

inputUser() {
	dialog --backtitle "$backtitle" --inputbox \
	"Insert the new user name" 10 80 "$username" 2> /tmp/inputbox.tmp.$$
	retval=$?
	input=`cat /tmp/inputbox.tmp.$$`
	rm -f /tmp/inputbox.tmp.$$

	case $retval in
		0) 
			username=$input
		  	;;
		1) 
			echo "Exiting..."
			exit
			;;
	esac
}

inputPassword() {
	dialog --backtitle "$backtitle" --inputbox \
	"Change password (or use the generated below)" 10 80 "$password" 2> /tmp/inputbox.tmp.$$
	retval=$?
	input=`cat /tmp/inputbox.tmp.$$`
	rm -f /tmp/inputbox.tmp.$$

	case $retval in
		0) 
			password=$input
		  	;;
		1) 
			echo "Exiting..." 
			exit
			;;
	esac
}

inputServerAlias() {
	dialog --backtitle "$backtitle" --inputbox \
	"Add Server Alias separated by space (Ex. test.com www.test.com))" 10 80 "www.$domain" 2> /tmp/inputbox.tmp.$$
	retval=$?
	input=`cat /tmp/inputbox.tmp.$$`
	rm -f /tmp/inputbox.tmp.$$

	case $retval in
		0) 
			aliases=$input
		  	;;
		1) 
			echo "Exiting..." 
			exit
			;;
	esac
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
	[ $? -eq 0 ] && echo "User \"$username\" has been added to system  with password: $password" || echo "Failed to add a user!"
}

assignPermissionsToWebRoot() {
	chown $username:www-data $web_root/$domain -R
}

errorDialog() {
	dialog --backtitle "$backtitle" --msgbox "$message" 10 80
}

checkIfUserExists() {
	ret=false
	getent passwd $username >/dev/null 2>&1 && ret=true
}

createLogFolder() {
	local directory="$web_root/$domain/$log_folder"
	mkdir $directory
	touch "$directory/access.log"
	touch "$directory/error.log"
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
	ErrorLog $web_root/$domain/log/error.log
	LogLevel error
	CustomLog $web_root/$domain/log/access.log combined
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

	echo -e $"Complete! \nYou now have a new Virtual Host"
	exit;
}

addLogAliases() {
	local directory="$web_root/$domain/$log_folder"

	ln -s $directory/access.log /var/log/apache2/${domain/./-}-access.log
	ln -s $directory/error.log /var/log/apache2/${domain/./-}-error.log
}

# --- START ---

# permissions
if [ "$(whoami)" != "root" ]; then
	echo "Root privileges are required to run this, try running with sudo..."
	exit 2
fi

checkIfDialogIsInstalled

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


