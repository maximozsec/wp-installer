#!/bin/bash
#AUTHOR = FNKOC <franco.c.colombino@gmail.com>
#GITHUB = https://github.com/fnk0c
#LAST UPDATE = 03/05/2015
#CHANGES:	ask user to set variables
#			typos
#			comments
#			dialog
#			generates wp-config.php

#START SCRIPT ##################################################################
server_root="/var/www"
wp_source="https://wordpress.org/latest.tar.gz"
user="wpuser"
database="wpdatabase"

green="\033[32m"
red="\033[31m"
white="\e[0;37m"
default="\033[00m"

#START SETTING VARIABLES #######################################################

dialog --title "Setting variables" --yesno "Use $server_root as server root?" 0 0

if [ "$?" = "1" ]
then 
	server_root=$( dialog --stdout --inputbox "Set server root:" 0 0 )
else
	continue
fi

dialog --title "Setting variables" --yesno "Set $database as WordPress \
Database?" 0 0

if [ "$?" = "1" ]
then 
	database=$( dialog --stdout --inputbox "Set WordPress DB name:" 0 0 )
else
	continue
fi

dialog --title "Setting variables" --yesno "Use $user as WordPress database \
username?" 0 0

if [ "$?" = "1" ]
then 
	user=$( dialog --stdout --inputbox "Set WordPress username:" 0 0 )
else
	continue
fi

dialog --title "setting variables" --msgbox \
"[Server Root] = $server_root \
[Database name] = $database \
[MySQL Username] = $user" 10 35 --and-widget

#END SETTING VARIABLES #########################################################

#INSTALLING DEPENDENCIES #######################################################

echo -e "$green [+] Installing dependencies $default"
sudo apt-get install apache2 php5 php5-gd php5-mysql libapache2-mod-php5 \
mysql-server

#END INSTALLING DEPENDENCIES ###################################################

#DOWNLOADING SOURCE ############################################################
echo -e "$green [+] Downloading Wordpress$default"
wget $wp_source
echo -e "$green [+] Unpacking Wordpress$default"
tar xpvf latest.tar.gz

#END DOWNLOADING SOURCE ########################################################

#COPING FILES TO SERVER ROOT ###################################################
echo -e "$green [+] Copying files to $server_root"
sudo rsync -avP wordpress/ $server_root

#SETTING PERMITIONS ############################################################
echo -e "$green [+] Changing permissions$default"
sudo chown www-data:www-data $server_root/* -R
local_user=`whoami`
sudo usermod -a -G www-data $local_user
mv $server_root/index.html $server_root/index.html.orig

#END SETTING PERMITIONS ########################################################

#CONFIGURING MYSQL DATABASE ####################################################
pass=$( dialog --stdout --inputbox "Type $user@localhost password" 0 0 )
echo -e "$green [+] Type MySQL root password $default"

Q1="CREATE DATABASE $database;"
Q2="CREATE USER $user@localhost;"
Q3="SET PASSWORD FOR $user@localhost= PASSWORD('$pass');"
Q4="GRANT ALL PRIVILEGES on $database.* TO $user@localhost;"
Q5="FLUSH PRIVILEGES;"
SQL=${Q1}${Q2}${Q3}${Q4}${Q5}

`mysql -u root -p -e "$SQL"`

#END CONFIGURING MYSQL DATABASE ################################################

#GENERATING WP-CONFIG.PHP ######################################################
cp $server_root/wp-config-sample.php $server_root/wp-config.php
sed -i "s/database_name_here/$database/g" $server_root/wp-config.php
sed -i "s/username_here/$user/g" $server_root/wp-config.php
sed -i "s/password_here/$pass/g" $server_root/wp-config.php

#FINISH GENERATING WP-CONFIG.PHP ###############################################

#FINISHING #####################################################################
dialog --title "Complete" --msgbox "Done!" 0 0
dialog --title "Complete" --yesno "Would you like to open your browser in order\
 to install WordPress? [Firefox]" 0 0

if [ $? = "1" ]
then
	echo -e "$red [!] Please, open your browser and access your WordPress in \
order to complete install$default"
	echo -e "$green [+] Bye! $default"
	exit
else
	echo -e "$green [+] Firefox started in background $default"
	`firefox --new-tab http://localhost &`
fi

#END SCRIPT ####################################################################
