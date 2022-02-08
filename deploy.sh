#Auto deploy Nodejs and other packages to prod

curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh

sudo bash nodesource_setup.sh

sudo apt install -y nodejs

sudo apt install -y build-essential mysql-server nginx wget


sudo update-alternatives --set editor /usr/bin/vim.basic

ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" -C "$1"


eval "$(ssh-agent -s)"

ssh-add -k ~/.ssh/id_rsa

RSA_KEY=$(cat ~/.ssh/id_rsa.pub)

#Disable StrictHostKeyChecking for git clone command
echo 'StrictHostKeyChecking no' >> ~/.ssh/config

#More https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
#Sometimes pasting these lines to other editors destroy the spacing encoding and the bash will fail to parse spaces
curl -H "Authorization: token $1" --data '{"title":"EC2-instance-'"$3"'-ID'"$RANDOM"'","key":"'"$RSA_KEY"'"}' https://api.github.com/user/keys

git clone --depth 1 git@github.com:$2/$3.git


sudo npm install nrm -g

nrm use taobao

sudo npm install pm2@latest node-gyp -g

sudo npm install

pm2 startOrGracefulReload ~/mshop/server/pm2.json
#This will start on localhost:8360

pm2 startup systemd

$(!! 2>&1 >/dev/null | grep 'sudo env')

#INSTALLING MYSQL 5.7 WHICH IS NOT SUPPORTED ON UBUNTU 20
#BUT NEED 5.7 TO BYPASS MYSQLJS LIBRARY BUG WITH MYSQL8

wget https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb

#This is interactively

#Choose Bionic Beaver, The next prompt shows MySQL 8.0 chosen. Click on MySQL 8 and Choose 5.7 and click OK
sudo dpkg -i mysql-apt-config_0.8.12-1_all.deb

sudo apt-get update

sudo apt-cache policy mysql-server

#sudo mysql
#
#create a user 
sudo mysql -e "CREATE USER '$3'@'localhost' IDENTIFIED BY $6"
sudo mysql -e "CREATE DATABASE $3 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"


sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$3'@'localhost' WITH GRANT OPTION"
sudo mysql -e "FLUSH PRIVILEGES"


mkdir ./logs
touch ./logs/nginx-access.log ./logs/nginx-error.log



sudo cp ~/prodjs/nginx.conf /etc/nginx/sites-available/$4

sudo ln -s /etc/nginx/sites-available/$4 /etc/nginx/sites-enabled

sudo rm /etc/nginx/sites-enabled/default


sudo nginx -t && sudo systemctl restart nginx


sudo apt-get update
sudo apt-get install python3-certbot-nginx -y
sudo certbot --noninteractive --agree-tos -d $4.$5 -d www.$4.$5 --register-unsafely-without-email --nginx


#If you have dump file 
#sudo mysql -u $3 -p $3 < ~/$3/location-to-dump.sql

