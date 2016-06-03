# Debian 8 (Jessie) nZEDb Guide
I make the assumption that anyone that is using this guide is familiar with Linux and the basic administration of it.  If not, I recommend you try the windows guide, or spend some time getting to know Linux.  I am by no means an expert as most of this was assembled through trial and error, analysis of other guides, and a basic working knowledge of Linux.

### 1.  Update System
Even with a fresh install, it is wise to make sure your system is fully updated.
```
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
```

### 2.  Database
Any version of MySQL, or equivalent, >= 5.5 will work, though 5.6 and above have numerous improvements, fixes, and features that make there use worthwhile.

#### - MySQL
>5.7 is the current stable. It's a good database server, but many will argue against using it since Oracle bought it. This seems to be a common belief in the community, since most of the major Linux distros have, or are, moving away from it as their default SQL server.

#### - Percona
> Mysql equivalent but with many improvements to innodb, Percona calls these XtraDB.

#### - MariaDB
> FLOSS fork of MySQL by the creators of MySQL, includes many updates and fixes not included in MySQL.
Includes XtraDB from Percona and TokuDB Support.
The current stable version is 10.1, though 10.0 is still supported and in most current distros repositories. I prefer MariaDB because it is very active and well supported by it's community.

##### Install MariaDB
 - Use the MariaDB repository configuration [tool](https://downloads.mariadb.org/mariadb/repositories/) to choose a version and local mirror, then install the repository. It will give you a similiar list of commands like those below.
```
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
sudo add-apt-repository 'deb [arch=amd64,i386] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/debian jessie main'
```

 - Install MariaDB server and client
```
sudo apt-get update
sudo apt-get install mariadb-server mariadb-client
```

##### Configure MariaDB
 - The default config from MariaDB has a mostly empty `my.cnf` that instructs the server to load any config files located in the `/etc/my.cnf.d/` directory.  By making a our own config file, we never need to worry about a patch overwriting our configs.
```
sudo nano /etc/my.cnf.d/nzedb.cnf
```
Paste into the above file with the following options:
```
[mysqld]
max_allowed_packet = 64M
group_concat_max_len = 8192
innodb_file_per_table = 1 (If you are using and/or planning to use innodb, this is recommended)
```

 - MySQL Time
The other guides say to set this, but I [know](https://mariadb.com/kb/en/mariadb/time-zones/#system-time-zone) that mysql will always use the system time by default.
And as timezone data is updated from time to time, you would have to manually update the SQL server every time this happens, to keep the following setting valid in your `nzedb.cnf`.
```
default_time_zone = America/New_York
```
The following command will insert the timezones into your database server, so that the default_time_zone will work.  This will take awhile as it is inserting quite a bit of info into the `mysql.time*` table.
```
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
(or if you have set a password in MySQL.)
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql
```
#### MySQL Tuning
The nZEDb guys have written a great starter for tuning your MySQL database [here](https://github.com/nZEDb/nZEDb/wiki/Database-tuning).

### 3. Web Server

#### Install Apache2 and PHP (PHP 5.6 is the default in Jessie)
`sudo apt-get install -y apache2 php5 php5-dev php-pear php5-gd php5-mysqlnd php5-curl`

 - Configure PHP options
```
sudo nano /etc/php5/apache2/php.ini
sudo nano /etc/php5/cli/php.ini
```
Edit the above files and change the following options:
```
max_execution_time = 120 (<300 recommended, but 120 is great for starting out)
memory_limit = 1024M (If your system is under 4GB of ram, 1024M is a safe limit)
memory_limit = -1 (If you have more than 4GB of RAM, this lets PHP manage it's memory limit)
date.timezone = America/New_York (You can find a list of valid time zones here: http://php.net/manual/en/timezones.php)
```
Add the following to the bottom of both files:
`register_globals = Off`

 - Configure Apache
```
sudo nano /etc/apache2/sites-available/nzedb.conf
```
Insert into the above file the following lines:
```
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName localhost
    DocumentRoot /var/www/nzedb/www
    LogLevel warn
    ServerSignature Off
    ErrorLog /var/log/apache2/error.log
    <Directory "/var/www/nzedb/www">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    Alias /covers /var/www/nzedb/resources/covers
</VirtualHost>
```
 - Run the following commands to disable the default website, enable our website, and enable a necessary module:
```
sudo a2dissite 000-default
sudo a2ensite nzedb
sudo a2enmod rewrite
sudo service apache2 restart
```

### 4.  Download nZEDb



### 5. Post processing software

#### Install software available from distribution repositories
```
sudo apt-get install lame mediainfo software-properties-common
```
##### ffmpeg
Debian no longer supports ffmpeg, libav-tools is provided from the repos. If you want to know why, google it.
Install libav-tools
```
sudo apt-get install libav-tools
```
Otherwise you can use my script to build it
```
download debian.sh
chmod +x debian.sh
./debian.sh
```
##### Unrar
If you plan on doing proper lookups and renames, you have to have unrar.
RAR 5 changed the structure of rar files and is not backwards compatible.
Since most distros have unrar < 5, or only provide a beta revision of 5.0 you may have
problems working with rar files, as rar 5 based files are becoming more common.
```
cd ~
wget http://www.rarlabs.com/rar/rarlinux-x64-5.4.b2.tar.gz (or whatever is the current version)
tar zxf rarlinux-x64*.tar.gz
cd rar
make install
```
### 6.  Install



### 7.  MISC

Additional recommended software

#### 7-Zip
While rar has been a mainstay of usenet for quite sometime, 7z archives are becoming more common do to it's better compression.
It is not strictly necessary as unrar includes support for it, but it is not always current with 7-Zip developement.
```
sudo apt-get install p7zip-full
```
#### Par2
This is software responsible for allowing repairs to damaged or incomplete downloads.
Never hurts to have a copy on your server.
```
sudo apt-get install par2
```
#### [Caching](https://github.com/nZEDb/nZEDb_Misc/blob/master/Guides/Various/Cache/Guide.md)
Good advice and much more indepth than I could hope to write.
For a personal server, I would recommend memcache.
For a public server, it would be best to try all of them and tune to your needs.
Personally I use APCu and IGBinary, they work well for my usage, YMMV.

#### Python
I have verified that these work on Debian 8.4 (Jessie). Though python 2 is deprecated, I have included it as a precaution for those that might be using custom scripts.

##### Python 2
```
sudo apt-get install python-setuptools python-pip
sudo python -m easy_install pip
sudo easy_install cymysql
pip list (Verify that cymysql is listed)
```
##### Python 3
```
sudo apt-get install python3-setuptools python3-pip
sudo python3 -m easy_install pip
sudo easy_install3 cymysql
pip3 list (Verify that cymysql is listed)
```
