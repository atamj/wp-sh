#!/bin/bash -e
clear
echo "============================================"
echo "WordPress Install Script"
echo "============================================"
echo "Nom du projet:"
read -e project
echo "Database Name: "
read -e dbname
echo "Database User: "
read -e dbuser
echo "Database Password: "
read -s dbpass
echo "Avez-vous déjà créer un BD pour ce projet ? (y/n)"
read -e bdExiste
if [ "$bdExiste" == n ]; then
	echo "Créer la BD avec 1-Mysql(natif), 2-Mysql(MAMP) ou 0-Aucun ? (1, 2 ou 0) "
	read -e mysql
	if [ "$mysql" == 1 ]; 
	then
		mysql --host=localhost -u"$dbuser" -p"$dbpass" -e "CREATE DATABASE $dbname;"
	elif [ "$mysql" == 2 ]; 
	then
		/Applications/MAMP/Library/bin/mysql --host=localhost -u"$dbuser" -p"$dbpass" -e "CREATE DATABASE $dbname;"
	else
		exit
	fi
fi
echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "=========================================================="
echo "Installation de la dernière version de WordPress."
echo "=========================================================="
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#rename folder project
mv wordpress/ "$project"
#change dir to wordpress project
cd "$project"
#create wp config
echo "Enregistrement de la configuration."
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php
#Installation du thème
echo "Téléchargement du thème."
#Deplacement dans le dossier wp-content
cd wp-content
#Déplacement dans le dossier thème
cd themes
git clone https://github.com/atamj/base_wp_underscores.git
echo "Yarn install"
cd base_wp_underscores
yarn install
echo "Cleaning..."
#remove git
rm -rf .git
#remove zip file
cd ..
cd ..
cd ..
cd ..
rm latest.tar.gz
#deplacer le projet
mv "$project" ../
cd ..
#remove bash script
echo "Voulez-vous supprimer le script wp.sh ?(y/n)"
read -e rmScript
if [ "$remScript" == y ]; then
	rm -rf wp-sh
fi
echo "========================="
echo "Installation is complete."
echo "========================="
echo "Lancer sublime text ? (y/n)"
read -e sublime
cd "$project"/wp-content/themes/base_wp_underscores
if [ "$sublime" == y ]; then
	subl .
fi
if [[ "$OSTYPE" == "darwin"*  ]]; 
then
	open http://localhost/"$project"
else
	xdg-open http://localhost/"$project"
fi
yarn watch
fi