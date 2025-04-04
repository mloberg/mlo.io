+++
title = 'The Perfect Dev Setup on OS X Lion 10.7'
slug = 'perfect-dev-setup-lion'
categories = ['devops']
proof = false
+++
A while back, I upgraded my work computer to Lion. Instead of doing a normal install, I installed Lion onto a flash drive and did a clean install. This gave me a chance to make my system exactly how I wanted it. I managed to get an almost perfect development setup. When my laptop's Ruby install got a little funny, I decided to do a clean install of Lion and follow the same setup, and document it set by set this time.

I am a PHP developer, I've also been developing with Ruby. So I'll need git, Apache, PHP, PEAR, MySQL, [Redis](http://redis.io/) (a key-value store), and Ruby.

#### Homebrew

I wanted to make installing these things as easy as possible, that's why I decided to go with [Homebrew](http://mxcl.github.com/homebrew/), a Mac package manager. There are other package managers out there, but I've found Homebrew to be the easiest to use.

To use Homebrew, you'll need some build tools installed. You could install Xcode, but there's an issue compiling using RVM (our Ruby install) with the newest version of Xcode. I had to uninstall Xcode and install [osx-gcc-installer](https://github.com/kennethreitz/osx-gcc-installer), so I would recommend just installing osx-gcc right from the get-go.

Once that's done, we can install Homebrew. Just open up Terminal enter enter

{{< highlight bash >}}
/usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
{{< /highlight >}}

#### Git

One of the most valuable tools I use, no matter what language I'm working with is git. You could easily go to [http://git-scm.com/](http://git-scm.com/) and download git from their, or even easier

{{< highlight bash >}}
brew install git
{{< /highlight >}}

#### Apache

Lion ships with Apache and PHP, but require some setup to get them to work how we want. It's at this point you'll need to decide where you want to keep your code at. I chose to keep all my code in a folder *Code* underneath my home directory and separated it by language from there.

We need to create a vhosts file that tells Apache about each of our sites. Let's create that file now.

{{< highlight bash >}}
mkdir -p ~/Code/php
touch ~/Code/php/httpd-vhosts.conf
sudo ln -s ~/Code/php/httpd-vhosts.conf /etc/apache2/other
{{< /highlight >}}

While we're at it, let's create a directory for log files generated by Apache.

{{< highlight bash >}}
mkdir ~/Code/php/logs
chmod 0777 ~/Code/php/logs
{{< /highlight >}}

We need to add some basic data to our vhosts file. Make sure you change */Users/name/Code/php* to match where you are storing your files.

{{< highlight apache >}}
NameVirtualHost *:80

<Directory "/Users/name/Code/php">
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	Allow from all
</Directory>

# default site
<VirtualHost _default_:80>
	ServerName localhost
	DocumentRoot /Library/WebServer/Documents
</VirtualHost>

# VHost Template
#<VirtualHost *:80>
#    ServerName domain.dev
#    CustomLog "/Users/name/Code/php/logs/domain.dev-access_log" combined
#    ErrorLog "/Users/name/Code/php/logs/domain.dev-error_log"
#    DocumentRoot "/Users/name/Code/php/domain.dev"
#</VirtualHost>
{{< /highlight >}}

**Note**: Some tutorials out there will use domain.local, do not use .local in your domains, this will slow down Apache incredibly!

We need to turn on Apache now. Go to **System Preferences** > **Sharing** and turn on **Web Sharing**. Visit `http://localhost/`. If you see "It Works!", you have successfully installed Apache.

To add a site, you'll need to copy the template, remove the comments, fill in the data, add an entry to /etc/hosts (*127.0.0.1 domain.dev*), and reload Apache (toggle Web Sharing off and on).

#### PHP

Let's make sure Apache is loading the PHP module, and create our php.ini file.

{{< highlight bash >}}
sudo sh -c "grep php /etc/apache2/httpd.conf|grep LoadModule|cut -d'#' -f2 > /etc/apache2/other/php5-loadmodule.conf"
sudo cp -a /etc/php.ini.default /etc/php.ini
{{< /highlight >}}

Make changes to */etc/php.ini* to fit your needs.

**Note**: If Apache runs slow, check out [this article](http://www.gigoblog.com/2011/09/06/apache-runs-slow-in-mac-os-x-lion-speed-up-apache-in-10-7/).

#### PEAR

PEAR is PHP's package manager. You'll need it to install packages like APC or Memcache(d).

{{< highlight bash >}}
sudo /usr/bin/php /usr/lib/php/install-pear-nozlib.phar
echo 'alias pear="php /usr/lib/php/pear/pearcmd.php"' >> ~/.bash_profile
echo 'alias pecl="php /usr/lib/php/pear/peclcmd.php"' >> ~/.bash_profile
. ~/.bash_profile
sudo pear channel-update pear.php.net
sudo pecl channel-update pecl.php.net
sudo pear upgrade --force pear
sudo pear upgrade
sudo pecl upgrade
{{< /highlight >}}

You'll need to change the *include_path* in /etc/php.ini from ".:/php/includes" to ".:/usr/lib/php/pear"

Now that PEAR is installed let's install APC. APC requires the pcre libraries, which we can install with Homebrew

{{< highlight bash >}}
brew install pcre
sudo pecl install apc
{{< /highlight >}}

You'll need to add these lines to the end of /etc/php.ini to active APC.

    extension=apc.so
    apc.enabled = 1
    apc.shm_segments = 1
    apc.shm_size = 32M
    apc.cache_by_default = 1
    apc.stat = 1
    apc.rfc1867 = 1
    apc.stat = 3600

Finally, toggle Web Sharing off and on to enable PHP.

#### MySQL

Let's finish our custom MAMP stack (Mac, Apache, MySQL, PHP) by installing MySQL. MySQL is a package in brew, so let's use that.

{{< highlight bash >}}
brew install mysql
{{< /highlight >}}

Once MySQL is installed, you need to configure it to work.

{{< highlight bash >}}
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
{{< /highlight >}}

If you want to autoload MySQL on login

{{< highlight bash >}}
mkdir -p ~/Library/LaunchAgents
cp /usr/local/Cellar/mysql/5.5.19/com.mysql.mysqld.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/com.mysql.mysqld.plist
{{< /highlight >}}

**Note**: If you are having issues, edit the plist to the correct *UserName*.

If you don't want to autoload MySQL, you have these commands to start and stop MySQL.

{{< highlight bash >}}
mysql.start
mysql.restart
mysql.stop
mysql.status
{{< /highlight >}}

It's recommended that you do a secure install (set a password and remove the test database and user).

{{< highlight bash >}}
/usr/local/Cellar/mysql/5.5.19/bin/mysql_secure_installation
{{< /highlight >}}

One final step for MySQL, PHP is looking for mysql.sock in /var/mysql, when it's actually in /tmp, so let's edit that.

{{< highlight bash >}}
sudo sed -i "" 's/\/var\/mysql\/mysql\.sock/\/tmp\/mysql\.sock/g' /etc/php.ini
{{< /highlight >}}

#### Redis

I find myself using Redis for a lot of my projects, so I installed that as well. If you don't use Redis, skip this step.

{{< highlight bash >}}
brew install redis
{{< /highlight >}}

To autoload on login.

{{< highlight bash >}}
cp /usr/local/Cellar/redis/2.4.6/io.redis.redis-server.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/io.redis.redis-server.plist
{{< /highlight >}}

#### Ruby

Lately I've been diving into Ruby. OS X comes with Ruby, but it's an old version. You could install the latest with Homebrew, but there's a better option, [Ruby Version Manager](http://beginrescueend.com/) or RVM. RVM allows you to have multiple versions of Ruby and switch between them. To install RVM simply run

{{< highlight bash >}}
bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
source ~/.bash_profile
{{< /highlight >}}

You can install different version of Ruby by running *rvm install [version]*. For example if you wanted to install 1.9.3 (the latest as of writing)

{{< highlight bash >}}
rvm install 1.9.3
{{< /highlight >}}

To use that version run

{{< highlight bash >}}
rvm use 1.9.3
{{< /highlight >}}

You can also set a default version

{{< highlight bash >}}
rvm use 1.9.3 --default
{{< /highlight >}}

Ruby Gems is also installed, so you can install your favorite gems

{{< highlight bash >}}
gem install bundler
{{< /highlight >}}

#### Other Packages

With Homebrew installed, it's easy to install other packages. Just search for the package.

{{< highlight bash >}}
bash search package
{{< /highlight >}}

For example I needed Nginx for a Ruby project I was working on

{{< highlight bash >}}
brew install nginx
{{< /highlight >}}

#### Conclusion

I've been running this setup on my work computer about a month and I haven't had any issue with it. I don't have to open up MAMP's preferences everytime I want to switch sites, or have seperate computers to test different versions of Ruby. I hope you find this setup as useful as I have. If you have any suggestions or comments, please share them.

*Update 2/9/12*: These steps also *mostly* work in Snow Leopard. You'll have to follow the instructions brew prints out for MySQL, but otherwise should be almost step for step.
