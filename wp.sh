#!/bin/bash -e
clear
echo "==============================================="
echo "	WordPress Install Script by Jaël"
echo "==============================================="
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
	#création de la bd
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
echo "	Installation de la dernière version de WordPress."
echo "=========================================================="
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#rename folder project
mv wordpress/ "$project"
#change dir to wordpress project
cd "$project"
echo ""
echo " 'y' si vous avez WP-CLI et que vous voulez l'utiliser (conseillé) sinon 'n' "
read -e wpcli
if [[ "$wpcli" == y ]]; then
	echo "Admin user:"
	read -e adminUser
	echo "Admin password:"
	read -s adminPass
	echo "Admin email:"
	read -e adminEmail
	wp core config --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass" --dbhost=localhost --dbprefix="$dbname"_
	wp core install --url=http://localhost/"$project" --title="$project" --admin_user="$adminUser" --admin_password="$adminPass" --admin_email="$adminEmail"
else
	"Création du wp-config.php ..."
	#create wp config
	cp wp-config-sample.php wp-config.php
	echo "Enregistrement de la configuration..."
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
fi

#Installation du thème
echo "Téléchargement du thème."
#Déplacement dans le dossier thème
cd wp-content/themes
#Téléchargement du thème
git clone https://github.com/atamj/base_wp_underscores.git
if [[ "$wpcli" == y ]]; then
	cd ../..
	wp theme activate base_wp_underscores
	cd wp-content/themes
fi
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
echo "Ouvrir votre navigateur par défaut à la fin de l'installation ? (y/n)"
read -e navigateur
echo "========================="
echo "Installation is complete."
echo "========================="
echo "Lancer sublime text ? (y/n)"
read -e sublime
if [ "$sublime" == y ]; then
	cd "$project"
	subl .
	cd /wp-content/themes/base_wp_underscores
else
	cd "$project"/wp-content/themes/base_wp_underscores
fi
if [[ "$navigateur" == y ]]; then
	if [[ "$OSTYPE" == "darwin"*  ]]; 
	then
		open http://localhost/"$project"
	else
		xdg-open http://localhost/"$project"
	fi
fi
yarn watch
fi