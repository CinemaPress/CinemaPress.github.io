#!/bin/bash

# CinemaPress ACMS - автоматическая система управления онлайн кинотеатром или каталогом фильмов.

R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
C='\033[0;34m'
B='\033[0;36m'
NC='\033[0m'

if [ "${EUID}" -ne 0 ]
then
	printf "${R}WARNING:${NC} Запустите с правами root пользователя!\n${NC}"
	exit 1
fi

if [ ! -f /etc/debian_version ]
then
	printf "${R}WARNING:${NC} Система работает только на Debian 7 x64 или Debian 8 x64!\n${NC}"
	exit 1
fi

logo() {
    printf  "  ${B} _______ ${G}_                        ${B} ______  ${G}                     \n"
    printf  "  ${B}(_______${G}|_)                       ${B}(_____ \ ${G}                     \n"
    printf  "  ${B} _      ${G} _ ____  _____ ____  _____${B} _____) )${G}___ _____  ___  ___  \n"
    printf  "  ${B}| |     ${G}| |  _ \| ___ |    \(____ ${B}|  ____/ ${G}___) ___ |/___)/___) \n"
    printf  "  ${B}| |_____${G}| | | | | ____| | | / ___ ${B}| |   ${G}| |   | ____|___ |___ | \n"
    printf  "  ${B} \______)${G}_|_| |_|_____)_|_|_\_____${B}|_|   ${G}|_|   |_____|___/(___/  \n"
    printf "\n${NC}"
}

read_domain() {
    printf "${C}--------------------------[ ${Y}URL ДОМЕНА${C} ]--------------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            DOMAIN=${1}
            DOMAIN=`echo ${DOMAIN} | iconv -c -t UTF-8`
            echo ": ${DOMAIN}"
        else
            read -e -p ': ' DOMAIN
            DOMAIN=`echo ${DOMAIN} | iconv -c -t UTF-8`
        fi
        if [ "${DOMAIN}" != "" ]
        then
            if echo "${DOMAIN}" | grep -qE ^\-?[.a-z0-9-]+$
            then
               AGAIN=no
            else
                printf "${NC}         Вы ввели - ${DOMAIN} \n"
                printf "${R}WARNING:${NC} Допускаются только латинские символы \n"
                printf "${NC}         в нижнем регистре, цифры, точки и дефисы! \n"
            fi
        else
            printf "${R}WARNING:${NC} URL домена не может быть пустым. \n"
        fi
    done
}

read_login() {
    printf "${C}---------------[ ${Y}ВАШ ЛОГИН ОТ АДМИН-ПАНЕЛИ И FTP${C} ]----------------\n${NC}"
    echo ": ${DOMAIN}"
}

read_theme() {
    printf "${C}-------------------------[ ${Y}НАЗВАНИЕ ТЕМЫ${C} ]------------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            THEME=${1}
            THEME=`echo ${THEME} | iconv -c -t UTF-8`
            echo ": ${THEME}"
        else
            read -e -p ': ' THEME
            THEME=`echo ${THEME} | iconv -c -t UTF-8`
        fi
        if [ "${THEME}" = "" ]
        then
            AGAIN=no
            THEME='default'
        else
            if [ "${THEME}" = "default" ] || [ "${THEME}" = "hodor" ] || [ "${THEME}" = "sansa" ] || [ "${THEME}" = "robb" ] || [ "${THEME}" = "ramsay" ] || [ "${THEME}" = "tyrion" ] || [ "${THEME}" = "cersei" ] || [ "${THEME}" = "joffrey" ] || [ "${THEME}" = "drogo" ] || [ "${THEME}" = "bran" ]
            then
                AGAIN=no
            else
                printf "${R}WARNING:${NC} Нет такой темы. На данный момент существуют темы: hodor, sansa, robb, ramsay, tyrion, cersei, joffrey, drogo и bran. \n"
            fi
        fi
    done
}

read_password() {
    printf "${C}-----------[ ${Y}ПРИДУМАЙТЕ ПАРОЛЬ ОТ АДМИН-ПАНЕЛИ И FTP${C} ]------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            PASSWD=${1}
            PASSWD=`echo ${PASSWD} | iconv -c -t UTF-8`
            echo ": ${PASSWD}"
        else
            read -e -p ': ' PASSWD
            PASSWD=`echo ${PASSWD} | iconv -c -t UTF-8`
        fi
        if [ "${PASSWD}" != "" ]
        then
            AGAIN=no
        else
            printf "${R}WARNING:${NC} Пароль от админ-панели и FTP не может быть пустым. \n"
        fi
    done
}

read_memcached() {
    printf "${C}----------[ ${Y}УКАЖИТЕ ДАННЫЕ MEMCACHED СЕРВЕРА IP:PORT${C} ]------------\n${NC}"
    if [ ${1} ]
    then
        MEMCACHED=${1}
        MEMCACHED=`echo ${MEMCACHED} | iconv -c -t UTF-8`
        echo ": ${MEMCACHED}"
    else
        read -e -p ': ' MEMCACHED
        MEMCACHED=`echo ${MEMCACHED} | iconv -c -t UTF-8`
    fi
    if [ "${MEMCACHED}" = "" ]
    then
        MEMCACHED="127.0.0.1:11211"
    fi
}

read_sphinx() {
    printf "${C}------------[ ${Y}УКАЖИТЕ ДАННЫЕ SPHINX СЕРВЕРА IP:PORT${C} ]-------------\n${NC}"
    if [ ${1} ]
    then
        MYSQL=${1}
        MYSQL=`echo ${MYSQL} | iconv -c -t UTF-8`
        echo ": ${MYSQL}"
    else
        read -e -p ': ' MYSQL
        MYSQL=`echo ${MYSQL} | iconv -c -t UTF-8`
    fi
    if [ "${MYSQL}" = "" ]
    then
        MYSQL="127.0.0.1:9306"
    fi
}

read_ip() {
    printf "${C}---------------------------[ ${Y}IP ДОМЕНА${C} ]--------------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            IP=${1}
            IP=`echo ${IP} | iconv -c -t UTF-8`
            echo ": ${IP}"
        else
            read -e -p ': ' IP
            IP=`echo ${IP} | iconv -c -t UTF-8`
        fi
        if [ "${IP}" != "" ]
        then
            if echo "${IP}" | grep -qE ^\-?[.0-9]+$
            then
               AGAIN=no
            else
                printf "${NC}         Вы ввели - ${IP} \n"
                printf "${R}WARNING:${NC} Допускаются только цифры и точки! \n"
            fi
        else
            printf "${R}WARNING:${NC} Укажите IP сервера на котором расположен сайт. \n"
        fi
    done
}

read_key() {
    printf "${C}-------------------------[ ${Y}КЛЮЧ ДОСТУПА${C} ]-------------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]; then
            KEY=${1}
            KEY=`echo ${KEY} | iconv -c -t UTF-8`
            echo ": ${KEY}"
        else
            read -e -p ': ' KEY
            KEY=`echo ${KEY} | iconv -c -t UTF-8`
        fi
        if [ "${KEY}" != "" ]
        then
            if echo "${KEY}" | grep -qE ^\-?[A-Za-z0-9]+$
            then
               AGAIN=no
            else
                printf "${NC}         Вы ввели - ${KEY} \n"
                printf "${R}WARNING:${NC} Допускаются только латинские символы и цифры! \n"
            fi
        else
            printf "${R}WARNING:${NC} Приобрести ключ можно в админ-панели Вашего сайта \n"
        fi
    done
}

read_mega_email() {
    printf "${C}---------------------[ ${Y}ВАШ EMAIL НА MEGA.NZ${C} ]---------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            MEGA_EMAIL=${1}
            MEGA_EMAIL=`echo ${MEGA_EMAIL} | iconv -c -t UTF-8`
            echo ": ${MEGA_EMAIL}"
        else
            read -e -p ': ' MEGA_EMAIL
            MEGA_EMAIL=`echo ${MEGA_EMAIL} | iconv -c -t UTF-8`
        fi
        if [ "${MEGA_EMAIL}" != "" ]
        then
            if echo "${MEGA_EMAIL}" | grep -qE ^\-?[.a-zA-Z0-9@-]+$
            then
               AGAIN=no
            else
                printf "${NC}         Вы ввели - ${MEGA_EMAIL} \n"
                printf "${R}WARNING:${NC} Допускаются только латинские символы, \n"
                printf "${NC}         цифры, точки и дефисы и собака! \n"
            fi
        else
            printf "${R}WARNING:${NC} Email пользователя не может быть пустым. \n"
        fi
    done
}

read_mega_password() {
    printf "${C}--------------------[ ${Y}ВАШ ПАРОЛЬ НА MEGA.NZ${C} ]---------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            MEGA_PASSWD=${1}
            MEGA_PASSWD=`echo ${MEGA_PASSWD} | iconv -c -t UTF-8`
            echo ": ${MEGA_PASSWD}"
        else
            read -e -p ': ' MEGA_PASSWD
            MEGA_PASSWD=`echo ${MEGA_PASSWD} | iconv -c -t UTF-8`
        fi
        if [ "${MEGA_PASSWD}" != "" ]
        then
            AGAIN=no
        else
            printf "${R}WARNING:${NC} Пароль не может быть пустым. \n"
        fi
    done
}

pre_install() {
    VER=`lsb_release -cs`
    if [ "`arch`" = "x86_64" ]; then ARCH="amd64"; else ARCH="i386"; fi
    echo "proftpd-basic shared/proftpd/inetd_or_standalone select standalone" | debconf-set-selections
    echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
    echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
    echo "check_certificate = off" > ~/.wgetrc
    echo "insecure" > ~/.curlrc
    echo "Acquire::https::deb.nodesource.com::Verify-Peer \"false\";" >> /etc/apt/apt.conf
    git config --global http.sslverify false
    timedatectl set-timezone 'Europe/Moscow'
    hash -r
}

update_server() {
    apt-get -y -qq update
    apt-get -y -qq install aptitude debian-keyring debian-archive-keyring wget curl nano htop sudo lsb-release ca-certificates git-core openssl netcat debconf-utils cron gzip
    pre_install
    echo -e "deb http://httpredir.debian.org/debian ${VER} main contrib non-free \ndeb-src http://httpredir.debian.org/debian ${VER} main contrib non-free \ndeb http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \ndeb-src http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \ndeb http://security.debian.org/ ${VER}/updates main contrib non-free \ndeb-src http://security.debian.org/ ${VER}/updates main contrib non-free \ndeb http://nginx.org/packages/debian/ ${VER} nginx \ndeb-src http://nginx.org/packages/debian/ ${VER} nginx \ndeb http://mirror.de.leaseweb.net/dotdeb/ ${VER} all \ndeb-src http://mirror.de.leaseweb.net/dotdeb/ ${VER} all" > /etc/apt/sources.list
    PHP=`php -v 2>/dev/null | grep -i "php"`
    if [ "${PHP}" = "" ] && [ "${VER}" = "wheezy" ]
    then
        echo "deb http://packages.dotdeb.org ${VER}-php56 all" >> /etc/apt/sources.list
        echo "deb-src http://packages.dotdeb.org ${VER}-php56 all" >> /etc/apt/sources.list
    fi
    wget -q http://www.dotdeb.org/dotdeb.gpg; apt-key add dotdeb.gpg
    wget -q http://nginx.org/keys/nginx_signing.key; apt-key add nginx_signing.key
    rm -rf dotdeb.gpg; rm -rf nginx_signing.key
    aptitude -y -q update
}

upgrade_server() {
    aptitude -y -q upgrade
}

install_full() {
    aptitude -y -q install nginx proftpd-basic openssl mysql-client memcached libltdl7 libodbc1 libpq5 fail2ban iptables-persistent curl libcurl3 php5-curl php5-cli php5-fpm
    NOD=`node -v 2>/dev/null`
    NPM=`npm -v 2>/dev/null`
    if [ "${NOD}" = "" ] || [ "${NPM}" = "" ]
    then
        wget -qO- https://deb.nodesource.com/setup_6.x | bash -
        aptitude -y -q install nodejs build-essential
    fi
    SPH=`dpkg --status sphinxsearch 2>/dev/null | grep "ok installed"`
    if [ "${SPH}" = "" ]
    then
        wget "https://github.com/sphinxsearch/sphinx/releases/download/2.2.11-release/sphinxsearch_2.2.11-release-1.${VER}_${ARCH}.deb" -qO s.deb && dpkg -i s.deb && rm -rf s.deb
    fi
    APC=`dpkg --status apache2 2>/dev/null | grep "ok installed"`
    if [ "${APC}" != "" ]
    then
        service nginx stop
        sleep 1
        service apache2 stop
        sleep 1
        service nginx stop
        sleep 1
        service nginx start
    fi
    PHP=`php -v 2>/dev/null | grep -i "php"`
    if [ "${PHP}" != "" ]
    then
        MODULES=$(php -i | awk -F '=> ' '/extension_dir/{print $3}')
        PHP_INI=$(php -i | awk -F '=> ' '/Loaded Configuration File/{print $2}')
        PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
        # FPM
        if [ -f "${PHP_INI/cli/fpm}" ]
        then
            PHP_INI_FPM="${PHP_INI/cli/fpm}"
        elif [ -f "${PHP_INI/cgi/fpm}" ]
        then
            PHP_INI_FPM="${PHP_INI/cgi/fpm}"
        elif [ -f "${PHP_INI/apache2/fpm}" ]
        then
            PHP_INI_FPM="${PHP_INI/apache2/fpm}"
        fi
        # APACHE2
        if [ -f "${PHP_INI/cli/apache2}" ]
        then
            PHP_INI_APACHE="${PHP_INI/cli/apache2}"
        elif [ -f "${PHP_INI/cgi/apache2}" ]
        then
            PHP_INI_APACHE="${PHP_INI/cgi/apache2}"
        elif [ -f "${PHP_INI/fpm/apache2}" ]
        then
            PHP_INI_APACHE="${PHP_INI/fpm/apache2}"
        fi
        # CGI
        if [ -f "${PHP_INI/cli/cgi}" ]
        then
            PHP_INI_CGI="${PHP_INI/cli/cgi}"
        elif [ -f "${PHP_INI/apache2/cgi}" ]
        then
            PHP_INI_CGI="${PHP_INI/apache2/cgi}"
        elif [ -f "${PHP_INI/fpm/cgi}" ]
        then
            PHP_INI_CGI="${PHP_INI/fpm/cgi}"
        fi
        echo "${PHP_INI} ${PHP_INI_FPM} ${PHP_INI_APACHE} ${PHP_INI_CGI}"
        if [ -d "${MODULES}" ]
        then
            if [ "`arch`" = "x86_64" ]
            then
                wget -qO "i.tar.gz" http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
            else
                wget -qO "i.tar.gz" http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
            fi
            tar xvfz "i.tar.gz"
            cp -r "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" "${MODULES}"
            rm -rf "i.tar.gz" && rm -rf "ioncube"
            if [ -f "${PHP_INI_FPM}" ] && [ "`grep \"ioncube\" \"${PHP_INI_FPM}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI_FPM}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI_FPM}"
            fi
            if [ -f "${PHP_INI_APACHE}" ] && [ "`grep \"ioncube\" \"${PHP_INI_APACHE}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI_APACHE}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI_APACHE}"
            fi
            if [ -f "${PHP_INI_CGI}" ] && [ "`grep \"ioncube\" \"${PHP_INI_CGI}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI_CGI}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI_CGI}"
            fi
            if [ -f "${PHP_INI}" ] && [ "`grep \"ioncube\" \"${PHP_INI}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI}"
            fi
            FPM=`dpkg --status php5-fpm 2>/dev/null | grep "ok installed"`
            if [ "${FPM}" != "" ]
            then
                service php5-fpm restart
            fi
        fi
    fi
}

install_cinemapress() {
    aptitude -y -q install nginx proftpd-basic openssl mysql-client libltdl7 libodbc1 libpq5 fail2ban iptables-persistent curl libcurl3 php5-curl php5-cli php5-fpm
    NOD=`node -v 2>/dev/null`
    NPM=`npm -v 2>/dev/null`
    if [ "${NOD}" = "" ] || [ "${NPM}" = "" ]
    then
        wget -qO- https://deb.nodesource.com/setup_6.x | bash -
        aptitude -y -q install nodejs build-essential
    fi
    APC=`dpkg --status apache2 2>/dev/null | grep "ok installed"`
    if [ "${APC}" != "" ]
    then
        service nginx stop
        sleep 1
        service apache2 stop
        sleep 1
        service nginx stop
        sleep 1
        service nginx start
    fi
    PHP=`php -v 2>/dev/null | grep -i "php"`
    if [ "${PHP}" != "" ]
    then
        MODULES=$(php -i | awk -F '=> ' '/extension_dir/{print $3}')
        PHP_INI=$(php -i | awk -F '=> ' '/Loaded Configuration File/{print $2}')
        PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
        # FPM
        if [ -f "${PHP_INI/cli/fpm}" ]
        then
            PHP_INI_FPM="${PHP_INI/cli/fpm}"
        elif [ -f "${PHP_INI/cgi/fpm}" ]
        then
            PHP_INI_FPM="${PHP_INI/cgi/fpm}"
        elif [ -f "${PHP_INI/apache2/fpm}" ]
        then
            PHP_INI_FPM="${PHP_INI/apache2/fpm}"
        fi
        # APACHE2
        if [ -f "${PHP_INI/cli/apache2}" ]
        then
            PHP_INI_APACHE="${PHP_INI/cli/apache2}"
        elif [ -f "${PHP_INI/cgi/apache2}" ]
        then
            PHP_INI_APACHE="${PHP_INI/cgi/apache2}"
        elif [ -f "${PHP_INI/fpm/apache2}" ]
        then
            PHP_INI_APACHE="${PHP_INI/fpm/apache2}"
        fi
        # CGI
        if [ -f "${PHP_INI/cli/cgi}" ]
        then
            PHP_INI_CGI="${PHP_INI/cli/cgi}"
        elif [ -f "${PHP_INI/apache2/cgi}" ]
        then
            PHP_INI_CGI="${PHP_INI/apache2/cgi}"
        elif [ -f "${PHP_INI/fpm/cgi}" ]
        then
            PHP_INI_CGI="${PHP_INI/fpm/cgi}"
        fi
        echo "${PHP_INI} ${PHP_INI_FPM} ${PHP_INI_APACHE} ${PHP_INI_CGI}"
        if [ -d "${MODULES}" ]
        then
            if [ "`arch`" = "x86_64" ]
            then
                wget -qO "i.tar.gz" http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
            else
                wget -qO "i.tar.gz" http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
            fi
            tar xvfz "i.tar.gz"
            cp -r "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" "${MODULES}"
            rm -rf "i.tar.gz" && rm -rf "ioncube"
            if [ -f "${PHP_INI_FPM}" ] && [ "`grep \"ioncube\" \"${PHP_INI_FPM}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI_FPM}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI_FPM}"
            fi
            if [ -f "${PHP_INI_APACHE}" ] && [ "`grep \"ioncube\" \"${PHP_INI_APACHE}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI_APACHE}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI_APACHE}"
            fi
            if [ -f "${PHP_INI_CGI}" ] && [ "`grep \"ioncube\" \"${PHP_INI_CGI}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI_CGI}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI_CGI}"
            fi
            if [ -f "${PHP_INI}" ] && [ "`grep \"ioncube\" \"${PHP_INI}\"`" = "" ]
            then
                echo "${MODULES} ${PHP_INI}"
                sed -i "1 izend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so\n" "${PHP_INI}"
            fi
            FPM=`dpkg --status php5-fpm 2>/dev/null | grep "ok installed"`
            if [ "${FPM}" != "" ]
            then
                service php5-fpm restart
            fi
        fi
    fi
}

install_memcached() {
    aptitude -y -q install memcached fail2ban iptables-persistent
}

install_sphinx() {
    aptitude -y -q install mysql-client libltdl7 libodbc1 libpq5 fail2ban iptables-persistent
    SPH=`dpkg --status sphinxsearch 2>/dev/null | grep "ok installed"`
    if [ "${SPH}" = "" ]
    then
        wget "https://github.com/sphinxsearch/sphinx/releases/download/2.2.11-release/sphinxsearch_2.2.11-release-1.${VER}_${ARCH}.deb" -qO s.deb && dpkg -i s.deb && rm -rf s.deb
    fi
}

add_user() {
    USR=`cat /etc/passwd | grep ${DOMAIN}:`
    if [ "${USR}" = "" ]
    then
        useradd ${DOMAIN} -m -U -s /bin/false
    else
        echo -e "${PASSWD}\n${PASSWD}" | passwd ${DOMAIN}
    fi
    rm -rf /home/${DOMAIN}/*; rm -rf /home/${DOMAIN}/.??*
    git clone https://${GIT_SERVER}/CinemaPress/CinemaPress-ACMS.git /home/${DOMAIN}
    cp -r /home/${DOMAIN}/config/default/* /home/${DOMAIN}/config/
    cp -r /home/${DOMAIN}/themes/default/public/admin/favicon.ico /home/${DOMAIN}/
    chown -R ${DOMAIN}:www-data /home/${DOMAIN}/
    cp -r ${0} /home/${DOMAIN}/config/i && chmod +x /home/${DOMAIN}/config/i
}

conf_nginx() {
    NGINX_PORT=33333
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        NGINX_PORT_TEST=`netstat -tunlp | grep ${NGINX_PORT}`
        if [ "${NGINX_PORT_TEST}" = "" ]
        then
            AGAIN=no
        else
            NGINX_PORT=$((NGINX_PORT+1))
        fi
    done
    rm -rf /etc/nginx/conf.d/rewrite.conf; rm -rf /etc/nginx/conf.d/${DOMAIN}.conf
    cp /home/${DOMAIN}/config/rewrite.conf /etc/nginx/conf.d/rewrite.conf
    sed -i "s/:3000/:${NGINX_PORT}/g" /home/${DOMAIN}/config/nginx.conf
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/nginx.conf
    cp /home/${DOMAIN}/config/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
    sed -i "s/user  nginx;/user  www-data;/g" /etc/nginx/nginx.conf
    sed -i "s/#gzip/ gzip_disable \"msie6\"; \n gzip_types text\/plain text\/css application\/json application\/x-javascript text\/xml application\/xml application\/xml+rss image\/svg+xml text\/javascript application\/javascript; \n gzip_vary on; \n gzip_proxied any; \n gzip_http_version 1.0; \n gzip/g" /etc/nginx/nginx.conf
    mv /etc/nginx/sites-enabled/default /etc/nginx/default
    SNHBS=`grep "server_names_hash_bucket_size" /etc/nginx/nginx.conf`
    if [ "${SNHBS}" = "" ]
    then
        sed -i "s/http {/http {\n\n    server_names_hash_bucket_size 64;\n/g" /etc/nginx/nginx.conf
    fi
    LRZ=`grep "zone=cinemapress" /etc/nginx/nginx.conf`
    if [ "${LRZ}" = "" ]
    then
        sed -i "s/http {/http {\n\n    limit_req_zone \$binary_remote_addr zone=cinemapress:10m rate=5r\/s;\n/g" /etc/nginx/nginx.conf
    fi
    rm -rf /etc/nginx/nginx_pass_${DOMAIN}
    OPENSSL=`echo "${PASSWD}" | openssl passwd -1 -stdin -salt CP`
    echo "${DOMAIN}:$OPENSSL" >> /etc/nginx/nginx_pass_${DOMAIN}
    service nginx restart
}

conf_sphinx() {
    SPHINX_PORT=39312
    MYSQL_PORT=29306
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        SPHINX_PORT_TEST=`netstat -tunlp | grep ${SPHINX_PORT}`
        MYSQL_PORT_TEST=`netstat -tunlp | grep ${MYSQL_PORT}`
        if [ "${SPHINX_PORT_TEST}" = "" ] && [ "${MYSQL_PORT_TEST}" = "" ]
        then
            AGAIN=no
        else
            MYSQL_PORT=$((MYSQL_PORT+1))
            SPHINX_PORT=$((SPHINX_PORT+1))
        fi
    done
    INDEX_DOMAIN=`echo ${DOMAIN} | sed -r "s/[^A-Za-z0-9]/_/g"`
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/sphinx.conf
    sed -i "s/example_com/${INDEX_DOMAIN}/g" /home/${DOMAIN}/config/sphinx.conf
    sed -i "s/:9306/:${MYSQL_PORT}/g" /home/${DOMAIN}/config/sphinx.conf
    sed -i "s/:9312/:${SPHINX_PORT}/g" /home/${DOMAIN}/config/sphinx.conf
    if [ "`grep \"${DOMAIN}_searchd\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_searchd --------------------------------------" >> /etc/crontab
        echo "@reboot root /home/${DOMAIN}/config/i cron searchd >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
        echo "# ----- ${DOMAIN}_searchd --------------------------------------" >> /etc/crontab
    fi
    if [ "${IP}" != "" ]
    then
        sed -i "s/127\.0\.0\.1:/0\.0\.0\.0:/g" /home/${DOMAIN}/config/sphinx.conf
        sed -i "s/= pool/= 0/g" /home/${DOMAIN}/config/sphinx.conf
        sed -i "s/= 128M/= 512M/g" /home/${DOMAIN}/config/sphinx.conf
    fi
    indexer --all --config "/home/${DOMAIN}/config/sphinx.conf" || indexer --all --rotate --config "/home/${DOMAIN}/config/sphinx.conf"
    searchd --config "/home/${DOMAIN}/config/sphinx.conf"
}

conf_proftpd() {
    sed -i "s/AuthUserFile    \/etc\/proftpd\/ftpd\.passwd//g" /etc/proftpd/proftpd.conf
    echo 'AuthUserFile    /etc/proftpd/ftpd.passwd' >> /etc/proftpd/proftpd.conf
    sed -i "s/\/bin\/false//g" /etc/shells
    echo '/bin/false' >> /etc/shells
    sed -i "s/# DefaultRoot/DefaultRoot/g" /etc/proftpd/proftpd.conf
    USERID=`id -u ${DOMAIN}`
    echo ${PASSWD} | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd --name=${DOMAIN} --shell=/bin/false --home=/home/${DOMAIN} --uid=${USERID} --gid=${USERID}
    service proftpd restart
}

conf_memcached() {
    MEMCACHED_PORT=51211
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        MEMCACHED_PORT_TEST=`netstat -tunlp | grep ${MEMCACHED_PORT}`
        if [ "${MEMCACHED_PORT_TEST}" = "" ]
        then
            AGAIN=no
        else
            MEMCACHED_PORT=$((MEMCACHED_PORT+1))
        fi
    done
    rm -rf /etc/memcached_${DOMAIN}.conf
    cp /etc/memcached.conf /etc/memcached_${DOMAIN}.conf
    sed -i "s/-p 11211/-p ${MEMCACHED_PORT}/g" /etc/memcached_${DOMAIN}.conf
    sed -i "s/-M/# -M/g" /etc/memcached_${DOMAIN}.conf
    if [ "${IP}" != "" ]
    then
        sed -i "s/-l 127\.0\.0\.1/-l 0\.0\.0\.0/g" /etc/memcached_${DOMAIN}.conf
    fi
    if [ "${VER}" = "jessie" ]
    then
        cp /lib/systemd/system/memcached.service /lib/systemd/system/memcached_${DOMAIN}.service
        sed -i "s/memcached\.conf/memcached_${DOMAIN}.conf/g" /lib/systemd/system/memcached_${DOMAIN}.service
        systemctl stop memcached_${DOMAIN}.service
        systemctl disable memcached_${DOMAIN}.service
        systemctl enable memcached_${DOMAIN}.service
        systemctl start memcached_${DOMAIN}.service
        systemctl stop memcached.service
        systemctl disable memcached.service
    else
        service memcached stop ${DOMAIN}
        service memcached start ${DOMAIN}
    fi
}

conf_cinemapress() {
    if [ "${THEME}" != "default" ]
    then
        git clone https://${GIT_SERVER}/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
        chown -R ${DOMAIN}:www-data /home/${DOMAIN}/themes
        sed -E -i "s/\"theme\":\s*\"[a-zA-Z0-9-]*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/config.js
    fi
    if [ "`grep \"${DOMAIN}_publish\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_publish --------------------------------------" >> /etc/crontab
        echo "@hourly root /home/${DOMAIN}/config/i cron publish >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
        echo "# ----- ${DOMAIN}_publish --------------------------------------" >> /etc/crontab
    fi
    if [ "`grep \"${DOMAIN}_abuse\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_abuse ----------------------------------------" >> /etc/crontab
        echo "@daily root /home/${DOMAIN}/config/i cron abuse >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
        echo "# ----- ${DOMAIN}_publish --------------------------------------" >> /etc/crontab
    fi
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/process.json
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/config.js
    sed -i "s/:3000/:${NGINX_PORT}/" /home/${DOMAIN}/config/config.js

    if [ "${MYSQL}" != "" ]
    then
        sed -i "s/127\.0\.0\.1:9306/${MYSQL}/" /home/${DOMAIN}/config/config.js
    else
        sed -i "s/:9306/:${MYSQL_PORT}/" /home/${DOMAIN}/config/config.js
    fi

    if [ "${MEMCACHED}" != "" ]
    then
        sed -i "s/127\.0\.0\.1:11211/${MEMCACHED}/" /home/${DOMAIN}/config/config.js
    else
        sed -i "s/:11211/:${MEMCACHED_PORT}/" /home/${DOMAIN}/config/config.js
    fi

    cp /home/${DOMAIN}/config/config.js /home/${DOMAIN}/config/config.prev.js
}

conf_sysctl() {
    mv /etc/sysctl.conf /etc/sysctl.old.conf
    cp /home/${DOMAIN}/config/sysctl.conf /etc/sysctl.conf
}

conf_fail2ban() {
    mv /etc/fail2ban/jail.local /etc/fail2ban/jail.old.local
    cp /home/${DOMAIN}/config/jail.conf /etc/fail2ban/jail.local
}

conf_iptables() {
    if [ "${MEMCACHED_PORT}" != "" ]
    then
        if [ "${IP}" != "" ]
        then
            iptables -A INPUT -p tcp -s ${IP} --dport ${MEMCACHED_PORT} -j ACCEPT
            iptables -A INPUT -p tcp --dport ${MEMCACHED_PORT} -j REJECT
        else
            iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${MEMCACHED_PORT} -j ACCEPT
            iptables -A INPUT -p tcp --dport ${MEMCACHED_PORT} -j REJECT
        fi
    fi
    if [ "${MYSQL_PORT}" != "" ]
    then
        if [ "${IP}" != "" ]
        then
            iptables -A INPUT -p tcp -s ${IP} --dport ${MYSQL_PORT} -j ACCEPT
            iptables -A INPUT -p tcp --dport ${MYSQL_PORT} -j REJECT
        else
            iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${MYSQL_PORT} -j ACCEPT
            iptables -A INPUT -p tcp --dport ${MYSQL_PORT} -j REJECT
        fi
    fi
    if [ "${SPHINX_PORT}" != "" ]
    then
        iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${SPHINX_PORT} -j ACCEPT
        iptables -A INPUT -p tcp --dport ${SPHINX_PORT} -j REJECT
    fi
    if [ "${NGINX_PORT}" != "" ]
    then
        iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${NGINX_PORT} -j ACCEPT
        iptables -A INPUT -p tcp --dport ${NGINX_PORT} -j REJECT
    fi
    iptables-save >/etc/iptables/rules.v4
    ip6tables-save >/etc/iptables/rules.v6
}

start_cinemapress() {
    cd /home/${DOMAIN}/ && npm install --loglevel=silent --parseable
    I=`npm list -g --depth=0 | grep "pm2"`
    if ! [ -n "${I}" ]
    then
        sleep 2
        npm install --loglevel=silent --parseable pm2 -g
        sleep 2
        pm2 startup
        sleep 2
        pm2 install pm2-logrotate
        sleep 2
    fi
    export NODE_ENV=production
    sleep 2
    cd /home/${DOMAIN}/ && pm2 start process.json && pm2 save
    sleep 2
    hash -r
}

conf_mass() {
    FILE_MASS=mass.txt
    if ! [ -f ${FILE_MASS} ]
    then
        printf "\n${NC}"
        printf "${C}-------------------------[ ${Y}ФАЙЛ НЕ НАЙДЕН${C} ]------------------------\n${NC}"
        printf "${C}----                                                           ${C}----\n${NC}"
        printf "${C}----         ${R}Создайте в текущей папке файл ${NC}mass.txt${R} и${C}          ----\n${NC}"
        printf "${C}----            ${R}пропишите в нем команды с заданиями.${C}           ----\n${NC}"
        printf "${C}----                ${R}Подробнее в этом руководстве:${C}              ----\n${NC}"
        printf "${C}----${R}cinemapress.org/article/chto-takoe-massovaya-ustanovka.html${C}----\n${NC}"
        printf "${C}----                                                           ${C}----\n${NC}"
        printf "${C}-------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
}

start_mass() {
    while read COMMAND
    do
        if [ "${COMMAND}" = "" ]
        then
            continue
        fi
        COM=`echo "${COMMAND}" | grep "#"`
        if [ "${COM}" = "" ]
        then
            sed -i "s|${COMMAND}|# [SUCCESS] ${COMMAND}|g" ${FILE_MASS}
            eval ${COMMAND}
        fi
    done < ${FILE_MASS}
}

success_2() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}--------------------[ ${Y}ОБНОВЛЕНИЕ ПРОИЗВЕДЕНО${C} ]--------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----       ${G}Если что-то не работает, свяжитесь с Нами.${C}         ----\n${NC}"
    printf "${C}----             ${G}email: support@cinemapress.org${C}               ----\n${NC}"
    printf "${C}----             ${G}skype: cinemapress${C}                           ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

fail_2() {
    printf "\n${NC}"
    printf "${C}----------------------------[ ${Y}ОТКАТ${C} ]-----------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----           ${NC}Откатываемся к рабочему состоянию,${C}             ----\n${NC}"
    printf "${C}----                   ${NC}осталось 5 сек ...${C}                     ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"

    rm -rf /home/${DOMAIN}/package.json && cp -R /home/${DOMAIN}/.oldCP/package.json /home/${DOMAIN}/package.json
    rm -rf /home/${DOMAIN}/process.json && cp -R /home/${DOMAIN}/.oldCP/process.json /home/${DOMAIN}/process.json
    rm -rf /home/${DOMAIN}/app.js && cp -R /home/${DOMAIN}/.oldCP/app.js /home/${DOMAIN}/app.js
    rm -rf /home/${DOMAIN}/modules/* && cp -R /home/${DOMAIN}/.oldCP/modules/* /home/${DOMAIN}/modules/
    rm -rf /home/${DOMAIN}/routes/* && cp -R /home/${DOMAIN}/.oldCP/routes/* /home/${DOMAIN}/routes/
    rm -rf /home/${DOMAIN}/lib/* && cp -R /home/${DOMAIN}/.oldCP/lib/* /home/${DOMAIN}/lib/
    rm -rf /home/${DOMAIN}/themes/default/* && cp -R /home/${DOMAIN}/.oldCP/themes/default/* /home/${DOMAIN}/themes/default/

    sleep 5

    chown -R ${DOMAIN}:www-data /home/${DOMAIN}

    cd /home/${DOMAIN}/
    pm2 delete ${DOMAIN} &> /dev/null
    pm2 start process.json
    pm2 save

    printf "\n${NC}"
    printf "${C}----------------[ ${Y}ОТКАТИЛИСЬ К РАБОЧЕМУ СОСТОЯНИЮ${C} ]---------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----       ${R}Свяжитесь с Нами, постараемся разобраться.${C}         ----\n${NC}"
    printf "${C}----             ${R}email: support@cinemapress.org${C}               ----\n${NC}"
    printf "${C}----             ${R}skype: cinemapress${C}                           ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

update_cinemapress() {
    rm -rf /home/${DOMAIN}/.newCP
    rm -rf /home/${DOMAIN}/.oldCP

    mkdir -p /home/${DOMAIN}/.newCP
    mkdir -p /home/${DOMAIN}/.oldCP

    git clone https://${GIT_SERVER}/CinemaPress/CinemaPress-ACMS.git /home/${DOMAIN}/.newCP
    cp -R /home/${DOMAIN}/* /home/${DOMAIN}/.oldCP

    rm -rf /home/${DOMAIN}/package.json && \
    cp -R /home/${DOMAIN}/.newCP/package.json /home/${DOMAIN}/package.json

    rm -rf /home/${DOMAIN}/process.json && \
    cp -R /home/${DOMAIN}/.newCP/process.json /home/${DOMAIN}/process.json

    rm -rf /home/${DOMAIN}/app.js && \
    cp -R /home/${DOMAIN}/.newCP/app.js /home/${DOMAIN}/app.js

    rm -rf /home/${DOMAIN}/modules/* && \
    cp -R /home/${DOMAIN}/.newCP/modules/* /home/${DOMAIN}/modules/

    rm -rf /home/${DOMAIN}/routes/* && \
    cp -R /home/${DOMAIN}/.newCP/routes/* /home/${DOMAIN}/routes/

    rm -rf /home/${DOMAIN}/lib/* && \
    cp -R /home/${DOMAIN}/.newCP/lib/* /home/${DOMAIN}/lib/

    rm -rf /home/${DOMAIN}/themes/default/* && \
    cp -R /home/${DOMAIN}/.newCP/themes/default/* /home/${DOMAIN}/themes/default/

    rm -rf /home/${DOMAIN}/config/default/* && \
    cp -R /home/${DOMAIN}/.newCP/config/default/* /home/${DOMAIN}/config/default/

    rm -rf /home/${DOMAIN}/config/i && \
    cp -R ${0} /home/${DOMAIN}/config/i

    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/process.json

    chown -R ${DOMAIN}:www-data /home/${DOMAIN}

    cd /home/${DOMAIN}/ && \
    npm i && \
    node ./config/update.js && \
    pm2 delete ${DOMAIN} &> /dev/null && \
    pm2 start process.json && \
    pm2 save
}

confirm_update_cinemapress() {
    printf "\n${NC}"
    printf "${C}-------------------------[ ${Y}ПОДТВЕРЖДЕНИЕ${C} ]------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----        ${NC}Перейдите в админ-панель и очистите кэш,${C}          ----\n${NC}"
    printf "${C}----  ${NC}затем зайдите на сайт и убедитесь что всё работает.${C}     ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Адрес сайта  - ${G}http://${DOMAIN}/\n${NC}"
    printf "     ${NC}Админ-панель - ${G}http://${DOMAIN}/admin\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    if [ ${1} ]
    then
        YES=${1}
        YES=`echo ${YES} | iconv -c -t UTF-8`
        echo "Всё работает? [ДА/нет] : ${YES}"
    else
        read -e -p 'Всё работает? [ДА/нет] : ' YES
        YES=`echo ${YES} | iconv -c -t UTF-8`
    fi
    printf "\n${NC}"

    if [ "${YES}" != "ДА" ] && [ "${YES}" != "Да" ] && [ "${YES}" != "да" ] && [ "${YES}" != "YES" ] && [ "${YES}" != "Yes" ] && [ "${YES}" != "yes" ] && [ "${YES}" != "Y" ] && [ "${YES}" != "y" ] && [ "${YES}" != "" ]
    then
        fail_2
    else
        success_2
    fi
}

update_theme() {
    if ! [ -d /home/${DOMAIN}/themes/${THEME} ]
    then
        git clone https://${GIT_SERVER}/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
    else
        printf "\n${NC}"
        printf "${C}-------------------------[ ${Y}ПОДТВЕРЖДЕНИЕ${C} ]------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----    ${NC}Данная тема уже установлена, хотите обновить её?${C}      ----\n${NC}"
        printf "${C}---- ${NC}Все изменения, которые Вы вносили в тему будут потеряны!${C} ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        if [ ${1} ]
        then
            YES=${1}
            YES=`echo ${YES} | iconv -c -t UTF-8`
            echo "Обновить? [ДА/нет] : ${YES}"
        else
            read -e -p 'Обновить? [ДА/нет] : ' YES
            YES=`echo ${YES} | iconv -c -t UTF-8`
        fi
        printf "\n${NC}"

        if [ "${YES}" != "ДА" ] && [ "${YES}" != "Да" ] && [ "${YES}" != "да" ] && [ "${YES}" != "YES" ] && [ "${YES}" != "Yes" ] && [ "${YES}" != "yes" ] && [ "${YES}" != "Y" ] && [ "${YES}" != "y" ] && [ "${YES}" != "" ]
        then
            exit 0
        else
            rm -rf /home/${DOMAIN}/themes/${THEME}
            git clone https://${GIT_SERVER}/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
        fi
    fi

    chown -R ${DOMAIN}:www-data /home/${DOMAIN}/themes
    sed -E -i "s/\"theme\":\s*\"[a-zA-Z0-9-]*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/config.js
    echo "Change theme to ${THEME}" >> /home/${DOMAIN}/restart.server
}

success_4() {
    curl -s -o /dev/null -I http://database.cinemapress.org/${KEY}/${DOMAIN}?status=SUCCESS

    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}--------------[ ${Y}БАЗА ДАННЫХ УСПЕШНО ИМПОРТИРОВАНА${C} ]---------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----       ${G}Если что-то не работает, свяжитесь с Нами.${C}         ----\n${NC}"
    printf "${C}----             ${G}email: support@cinemapress.org${C}               ----\n${NC}"
    printf "${C}----             ${G}skype: cinemapress${C}                           ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

fail_4() {
    printf "\n${NC}"
    printf "${C}----------------------------[ ${Y}ОТКАТ${C} ]-----------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----           ${NC}Откатываемся к рабочему состоянию,${C}             ----\n${NC}"
    printf "${C}----                  ${NC}осталось 5 сек ...${C}                      ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"

    searchd --stop --config "/home/${DOMAIN}/config/sphinx.conf"

    rm -rf /var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.*

    cp -R /var/lib/sphinxsearch/old/movies_${INDEX_DOMAIN}.* /var/lib/sphinxsearch/data/

    sleep 5

    searchd --config "/home/${DOMAIN}/config/sphinx.conf"

    curl -s -o /dev/null -I http://database.cinemapress.org/${KEY}/${DOMAIN}?status=FAIL

    printf "\n${NC}"
    printf "${C}----------------[ ${Y}ОТКАТИЛИСЬ К РАБОЧЕМУ СОСТОЯНИЮ${C} ]---------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----       ${R}Свяжитесь с Нами, постараемся разобраться.${C}         ----\n${NC}"
    printf "${C}----             ${R}email: support@cinemapress.org${C}               ----\n${NC}"
    printf "${C}----             ${R}skype: cinemapress${C}                           ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

check_db() {
    STATUS=`curl -s -o /dev/null -I -w "%{http_code}" http://database.cinemapress.org/${KEY}/${DOMAIN}?status=CHECK`

    if [ "${STATUS}" != "200" ]
    then
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----         ${R}Сервер базы данных временно недоступен,${C}          ----\n${NC}"
        printf "${C}----             ${R}пожалуйста, попробуйте позже ...${C}             ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
}

import_db() {
    NOW=$(date +%Y-%m-%d)

    searchd --stop --config "/home/${DOMAIN}/config/sphinx.conf" &> /var/lib/sphinxsearch/data/${NOW}.log

    sleep 5

    mkdir -p /var/lib/sphinxsearch/tmp
    rm -rf /var/lib/sphinxsearch/tmp/*

    printf "${G}Загрузка ...\n"

    wget -qO "/var/lib/sphinxsearch/tmp/${KEY}.tar.gz" http://database.cinemapress.org/${KEY}/${DOMAIN} || \
    rm -f "/var/lib/sphinxsearch/tmp/${KEY}.tar.gz"

    if [ -f "/var/lib/sphinxsearch/tmp/${KEY}.tar.gz" ]
    then
        printf "${G}Распаковка ...\n"

        INDEX_DOMAIN=`echo ${DOMAIN} | sed -r "s/[^A-Za-z0-9]/_/g"`

        mkdir -p /var/lib/sphinxsearch/data
        mkdir -p /var/lib/sphinxsearch/old

        rm -rf /var/lib/sphinxsearch/old/movies_${INDEX_DOMAIN}.*

        cp -R /var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.* /var/lib/sphinxsearch/old/

        rm -rf /var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.*

        tar -xzf "/var/lib/sphinxsearch/tmp/${KEY}.tar.gz" -C "/var/lib/sphinxsearch/tmp" &> /var/lib/sphinxsearch/data/${NOW}.log

        printf "${G}Установка ...\n"

        sleep 3

        rm -rf "/var/lib/sphinxsearch/tmp/${KEY}.tar.gz"

        FILENAME=`find /var/lib/sphinxsearch/tmp/*.* -type f | grep spa`

        if [ -f "${FILENAME}" ]
        then
            for file in `find /var/lib/sphinxsearch/tmp/*.* -type f`
            do
                mv ${file} "/var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.${file##*.}"
            done
        fi

        printf "${G}Запуск ...\n"

        searchd --config "/home/${DOMAIN}/config/sphinx.conf" &> /var/lib/sphinxsearch/data/${NOW}.log

        NOW=$(date +%Y-%m-%d)
        sed -E -i "s/\"key\":\s*\"[a-zA-Z0-9-]*\"/\"key\":\"${KEY}\"/" /home/${DOMAIN}/config/config.js
        sed -E -i "s/\"date\":\s*\"[0-9-]*\"/\"date\":\"${NOW}\"/" /home/${DOMAIN}/config/config.js

        sleep 10
    else
        searchd --config "/home/${DOMAIN}/config/sphinx.conf" &> /var/lib/sphinxsearch/data/${NOW}.log
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----             ${R}База фильмов не была загружена,${C}              ----\n${NC}"
        printf "${C}----          ${R}возможно у Вас закончились обновления${C}           ----\n${NC}"
        printf "${C}----                   ${R}на тарифе EXPANDED,${C}                    ----\n${NC}"
        printf "${C}----      ${R}либо Вы используете ключ START несколько раз.${C}       ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
}

confirm_import_db() {
    printf "\n${NC}"
    printf "${C}-------------------------[ ${Y}ПОДТВЕРЖДЕНИЕ${C} ]------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----        ${NC}Перейдите в админ-панель и очистите кэш,${C}          ----\n${NC}"
    printf "${C}----  ${NC}затем зайдите на сайт и убедитесь, что всё работает.${C}    ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Адрес сайта  - ${G}http://${DOMAIN}/\n${NC}"
    printf "     ${NC}Админ-панель - ${G}http://${DOMAIN}/admin\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    if [ ${1} ]
    then
        YES=${1}
        YES=`echo ${YES} | iconv -c -t UTF-8`
        echo "Всё работает? [ДА/нет] : ${YES}"
    else
        read -e -p 'Всё работает? [ДА/нет] : ' YES
        YES=`echo ${YES} | iconv -c -t UTF-8`
    fi
    printf "\n${NC}"

    if [ "${YES}" != "ДА" ] && [ "${YES}" != "Да" ] && [ "${YES}" != "да" ] && [ "${YES}" != "YES" ] && [ "${YES}" != "Yes" ] && [ "${YES}" != "yes" ] && [ "${YES}" != "Y" ] && [ "${YES}" != "y" ] && [ "${YES}" != "" ]
    then
        fail_4
    else
        success_4
    fi
}

import_static() {
    wget -O /home/images.tar http://static.cinemapress.org/images.tar
    mkdir -p /var/local/images
    printf "\n${NC}"
    printf "${G}Распаковка ...\n"
    printf "${NC}Может занять до 20 минут.\n"
    printf "\n${NC}"
    tar -xf /home/images.tar -C /var/local/images
    wget http://cinemapress.org/images/web/no-poster.gif -qO /var/local/images/poster/no-poster.gif
}

check_domain() {
    STATUS=`curl -s -o /dev/null -I -w "%{http_code}" http://${DOMAIN}`

    if [ "${STATUS}" != "200" ]
    then
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----       ${R}Данный сайт недоступен, устраните проблему${C}         ----\n${NC}"
        printf "${C}----                  ${R}и попробуйте позже ...${C}                  ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi

    STATUS_MOBILE=`curl -s -o /dev/null -I -w "%{http_code}" http://m.${DOMAIN}`

    if [ "${STATUS_MOBILE}" != "200" ]
    then
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----  ${R}Мобильная версия сайта недоступна, устраните проблему${C}   ----\n${NC}"
        printf "${C}----                  ${R}и попробуйте позже ...${C}                  ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
}

get_ssl() {
    wget https://dl.eff.org/certbot-auto -O /etc/certbot-auto
    chmod a+x /etc/certbot-auto
    /etc/certbot-auto certonly --non-interactive --webroot --renew-by-default --agree-tos --email support@${DOMAIN} -w /home/${DOMAIN}/ -d ${DOMAIN} -d m.${DOMAIN}
    openssl dhparam -out /etc/letsencrypt/live/${DOMAIN}/dhparam.pem 2048
    sed -i "s/#ssl/ssl/g" /home/${DOMAIN}/config/nginx.conf
    sed -i "s/#listen/listen/g" /home/${DOMAIN}/config/nginx.conf
    cp /home/${DOMAIN}/config/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
    if [ "`grep \"renew_ssl\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- renew_ssl --------------------------------------" >> /etc/crontab
        echo "40 5 * * 1 root /etc/certbot-auto renew --quiet --post-hook \"service nginx reload\" >> /var/log/le-renew.log" >> /etc/crontab
        echo "# ----- renew_ssl --------------------------------------" >> /etc/crontab
    fi
    service nginx restart
}

create_mega_backup() {
    if [ "`grep \"${DOMAIN}_backup\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_backup --------------------------------------" >> /etc/crontab
        echo "@daily root /home/${DOMAIN}/config/i cron backup \"${DOMAIN}\" \"${MEGA_EMAIL}\" \"${MEGA_PASSWD}\" >> /home/${DOMAIN}/config/autostart.log" >> /etc/crontab
        echo "# ----- ${DOMAIN}_backup --------------------------------------" >> /etc/crontab
    fi
    MEGA_NOW=$(date +%Y-%m-%d)
    MEGA_DELETE=$(date +%Y-%m-%d -d "10 day ago")
    THEME_NAME=`grep "theme" /home/${DOMAIN}/config/config.js | sed 's/.*"theme":\s*"\([a-zA-Z0-9-]*\)".*/\1/'`
    megarm -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/${MEGA_NOW}/ &> /dev/null
    megarm -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/${MEGA_DELETE} &> /dev/null
    megarm -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/latest &> /dev/null
    sleep 3
    megamkdir -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/ &> /dev/null
    megamkdir -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/${MEGA_NOW}/
    megamkdir -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/latest/
    sleep 3
    rm -rf /tmp/${DOMAIN} && mkdir -p /tmp/${DOMAIN} && cd /home/${DOMAIN} && \
    tar -uf /tmp/${DOMAIN}/config.tar \
        config/config.js \
        config/modules.js \
        config/texts.js && \
    tar -uf /tmp/${DOMAIN}/themes.tar \
        themes/default/public/desktop \
        themes/default/public/mobile \
        themes/${THEME_NAME}
    sleep 3
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/${MEGA_NOW}/config.tar \
        /tmp/${DOMAIN}/config.tar
    sleep 1
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/${MEGA_NOW}/themes.tar \
        /tmp/${DOMAIN}/themes.tar
    sleep 1
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/latest/config.tar \
        /tmp/${DOMAIN}/config.tar
    sleep 1
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/latest/themes.tar \
        /tmp/${DOMAIN}/themes.tar
    sleep 3
    rm -rf /tmp/${DOMAIN}
    printf "${C}-----------------------------[ ${Y}БЭКАП${C} ]----------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----      ${NC}Бэкап успешно создан и установлен автозапуск.${C}       ----\n${NC}"
    printf "${C}----      ${NC}Каждый день будет создаваться новая резервная${C}       ----\n${NC}"
    printf "${C}----       ${NC}копия конфигурационных файлов и темы сайта.${C}        ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

recover_mega_backup() {
    rm -rf /tmp/${DOMAIN} && mkdir -p /tmp/${DOMAIN}
    megaget -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" \
        --path /tmp/${DOMAIN}/ \
        /Root/${DOMAIN}/latest/config.tar
    megaget -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" \
        --path /tmp/${DOMAIN}/ \
        /Root/${DOMAIN}/latest/themes.tar
    cd /home/${DOMAIN} && tar -xf /tmp/${DOMAIN}/config.tar && tar -xf /tmp/${DOMAIN}/themes.tar
    printf "\n${NC}"
    chown -R ${DOMAIN}:www-data /home/${DOMAIN}
    cd /home/${DOMAIN}/ && \
    node ./config/update.js && \
    pm2 delete ${DOMAIN} &> /dev/null && \
    pm2 start process.json && \
    pm2 save
    printf "\n${NC}"
    printf "${C}-----------------------------[ ${Y}БЭКАП${C} ]----------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----        ${NC}Восстановление сайта из бэкапа выполнено.${C}         ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

remove_mega_backup() {
    if [ "`grep \"${DOMAIN}_backup\" /etc/crontab`" != "" ]
    then
        sed -i "s/# ----- ${DOMAIN}_backup --------------------------------------//g" /etc/crontab
        sed -i "s/@daily root \/home\/${DOMAIN}.*//g" /etc/crontab
    fi
    printf "${C}-----------------------------[ ${Y}БЭКАП${C} ]----------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----         ${NC}Бэкап сайта больше не будет создаваться.${C}         ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

confirm_mega_backup() {
    MGT=`megals --help 2>/dev/null | grep "list files stored"`
    if [ "${MGT}" = "" ]
    then
        printf "\n${NC}"
        printf "${C}---------------------------[ ${Y}УСТАНОВКА${C} ]--------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----           ${NC}Выполняется установка MegaTools ...${C}            ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        VER=`lsb_release -cs`
        sed -i s/${VER}/stretch/g /etc/apt/sources.list
        aptitude update
        aptitude -y -q install megatools
        sed -i s/stretch/${VER}/g /etc/apt/sources.list
        aptitude update
    fi
    MEGA_LS=`megals -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Contacts 2>/dev/null || echo "error"`
    if [ "${MEGA_LS}" = "error" ]
    then
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}БЭКАП${C} ]----------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----            ${R}Email/пароль указаны неправильно,${C}             ----\n${NC}"
        printf "${C}----             ${R}пожалуйста, попробуйте еще раз.${C}              ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
    printf "${C}-------------------------[ ${Y}СДЕЛАЙТЕ ВЫБОР${C} ]-----------------------\n${NC}"
    printf "${C}---- ${G}1)${NC} Запустить бэкап                                       ${C}----\n${NC}"
    printf "${C}---- ${G}2)${NC} Восстановить последний бэкап сайта                    ${C}----\n${NC}"
    printf "${C}---- ${G}3)${NC} Остановить бэкап                                      ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    if [ ${1} ]
    then
        CMB=${1}
        echo "ВАРИАНТ [1-3]: ${CMB}"
    else
        read -e -p 'ВАРИАНТ [1-3]: ' CMB
        CMB=`echo ${CMB} | iconv -c -t UTF-8`
    fi
    printf "\n${NC}"
    if [ "${CMB}" = "2" ]
    then
        recover_mega_backup
    elif [ "${CMB}" = "3" ]
    then
        remove_mega_backup
    else
        create_mega_backup
    fi
}

fail_1() {
    INST_NODE=`dpkg --status nodejs 2>/dev/null | grep "ok installed"`
    INST_NGINX=`dpkg --status nginx 2>/dev/null | grep "ok installed"`
    INST_SPHINX=`dpkg --status sphinxsearch 2>/dev/null | grep "ok installed"`
    if ! [ "${INST_NODE}" = "" ] || [ "${INST_NGINX}" = "" ] || [ "${INST_SPHINX}" = "" ]
    then
        printf "\n${NC}"
        printf "${C}---------------------------[ ${Y}ОШИБКА${C} ]-----------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----           ${NC}Один или несколько пакетов не были${C}             ----\n${NC}"
        printf "${C}----                ${NC}установлены в системе${C}                     ----\n${NC}"
        printf "SPHINX : ${G}${INST_SPHINX}\n${NC}"
        printf "NGINX  : ${G}${INST_NGINX}\n${NC}"
        printf "NODE   : ${G}${INST_NODE}\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
}

success_1() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}------------------------[ ${Y}CINEMAPRESS ACMS${C} ]----------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----        ${G}УРА! Ваш онлайн кинотеатр готов к работе!${C}         ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Адрес сайта  - ${G}http://${DOMAIN}/\n${NC}"
    printf "     ${NC}Админ-панель - ${G}http://${DOMAIN}/admin\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----           ${NC}Данные для доступа к админ-панели${C}              ----\n${NC}"
    printf "${C}----                      ${NC}и FTP сайта${C}                         ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Логин  : ${G}${DOMAIN}\n${NC}"
    printf "     ${NC}Пароль : ${G}${PASSWD}\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----      ${NC}Если что-то не работает, перезагрузите сервер.      ${C}----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_3() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}-----------------------[ ${Y}CINEMAPRESS THEME${C} ]----------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----                 ${G}Тема успешно установлена!${C}                ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_5() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}------------------------[ ${Y}CINEMAPRESS ACMS${C} ]----------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----        ${G}УРА! Ваш онлайн кинотеатр готов к работе!${C}         ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Адрес сайта  - ${G}http://${DOMAIN}/\n${NC}"
    printf "     ${NC}Админ-панель - ${G}http://${DOMAIN}/admin\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----     ${NC}Если что-то не работает, перезагрузите сервер.${C}       ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_6() {
    MYSQL_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}----------------------------[ ${Y}SPHINX${C} ]----------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----            ${G}УРА! Sphinx сервер готов к работе!${C}            ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Адрес сайта  - ${G}http://${DOMAIN}/\n${NC}"
    printf "     ${NC}Админ-панель - ${G}http://${DOMAIN}/admin\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----       ${G}Установите настройки Sphinx в админ-панели:${C}        ----\n${NC}"
    printf "                       ${R}${MYSQL_IP}:${MYSQL_PORT}\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----     ${NC}Если что-то не работает, перезагрузите сервер.${C}       ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_7() {
    MEMCACHED_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}--------------------------[ ${Y}MEMCACHED${C} ]---------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----          ${G}УРА! Memcached сервер готов к работе!${C}           ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Адрес сайта  - ${G}http://${DOMAIN}/\n${NC}"
    printf "     ${NC}Админ-панель - ${G}http://${DOMAIN}/admin\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----     ${G}Установите настройки Memcached в админ-панели:${C}       ----\n${NC}"
    printf "                       ${R}${MEMCACHED_IP}:${MEMCACHED_PORT}                  \n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----     ${NC}Если что-то не работает, перезагрузите сервер.${C}       ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_8() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}----------------------[ ${Y}МАССОВЫЕ ДЕЙСТВИЯ${C} ]-----------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----          ${G}УРА! Все команды в mass.txt выполнены!${C}          ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----     ${NC}Если что-то не работает, перезагрузите сервер.${C}       ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_9() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}------------------[ ${Y}ИМПОРТ СТАТИЧЕСКИХ ФАЙЛОВ${C} ]-------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----       ${G}УРА! Все статические файлы импортированы!${C}          ----\n${NC}"
    printf "${C}----     ${G}Чтобы все постеры отдавались с Вашего домена${C}         ----\n${NC}"
    printf "${C}----                ${G}измените в админ-панели${C}                   ----\n${NC}"
    printf "${C}----      ${G}«Распределение нагрузки» -> «Сервер картинок»${C}       ----\n${NC}"
    printf "${C}----                  ${G}на URL Вашего домена.${C}                   ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----     ${NC}Если что-то не работает, перезагрузите сервер.       ${C}----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_10() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}------------------[ ${Y}ПОЛУЧЕНИЕ SSL-СЕРТИФИКАТА${C} ]-------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----             ${G}УРА! Сертификат успешно получен!${C}             ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}HTTPS-адрес сайта  - ${G}https://${DOMAIN}/\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

success_11() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}------------------[ ${Y}ПОЛУЧЕНИЕ SSL-СЕРТИФИКАТА${C} ]-------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----             ${G}УРА! Сертификат успешно получен!${C}             ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}HTTPS-адрес сайта  - ${G}https://${DOMAIN}/\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

separator() {
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

option() {
    clear
    printf "${C}------------------------------------------------------------------\n${NC}"
    logo
    printf "${C}------------------------[ ${Y}СДЕЛАЙТЕ ВЫБОР${C} ]------------------------\n${NC}"
    printf "${C}---- ${G}1)${NC} Создание онлайн кинотеатра                            ${C}----\n${NC}"
    printf "${C}---- ${G}2)${NC} Обновление CinemaPress ACMS                           ${C}----\n${NC}"
    printf "${C}---- ${G}3)${NC} Установка/обновление шаблона                          ${C}----\n${NC}"
    printf "${C}---- ${G}4)${NC} Добавление/обновление всех фильмов в мире             ${C}----\n${NC}"
    printf "${C}---- ${G}5)${NC} Установка CinemaPress ACMS на отдельный сервер        ${C}----\n${NC}"
    printf "${C}---- ${G}6)${NC} Установка Sphinx на отдельный сервер                  ${C}----\n${NC}"
    printf "${C}---- ${G}7)${NC} Установка Memcached на отдельный сервер               ${C}----\n${NC}"
    printf "${C}---- ${G}8)${NC} Массовая установка/обновление/добавление              ${C}----\n${NC}"
    printf "${C}---- ${G}9)${NC} Импорт статических файлов на сервер                   ${C}----\n${NC}"
    printf "${C}---- ${G}10)${NC} Получение SSL-сертификата                            ${C}----\n${NC}"
    printf "${C}---- ${G}11)${NC} Создание/восстановление бэкапа                       ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            OPTION=${1}
            echo "ВАРИАНТ [1-11]: ${OPTION}"
        else
            read -e -p 'ВАРИАНТ [1-11]: ' OPTION
            OPTION=`echo ${OPTION} | iconv -c -t UTF-8`
        fi
        if [ "${OPTION}" != "" ]
        then
            if echo "${OPTION}" | grep -qE ^\-?[0-9]+$
            then
               AGAIN=no
            else
                printf "${R}WARNING:${NC} Введите цифру варианта. \n"
            fi
        else
            printf "${R}WARNING:${NC} Сделайте Ваш выбор. \n"
        fi
    done
    printf "\n${NC}"
}

whileStop() {
    WHILE=no
}

INSTALL_FILE=`basename "$0"`
case ${INSTALL_FILE} in
    h )
        MAIN_SERVER="cinemapress.github.io"
        GIT_SERVER="github.com"
    ;;
    l )
        MAIN_SERVER="cinemapress.gitlab.io"
        GIT_SERVER="gitlab.com"
    ;;
    c )
        MAIN_SERVER="cinemapress.coding.me"
        GIT_SERVER="git.coding.net"
    ;;
    b )
        MAIN_SERVER="cinemapress.bitbucket.io"
        GIT_SERVER="bitbucket.org"
    ;;
    a )
        MAIN_SERVER="cinemapress.aerobatic.io"
        GIT_SERVER="git.coding.net"
    ;;
    * )
        MAIN_SERVER="cinemapress.org"
        GIT_SERVER="github.com"
    ;;
esac

WHILE=yes
while [ "${WHILE}" = "yes" ]
do
    case ${OPTION} in
        1 )
            read_domain ${2}
            read_theme ${3}
            read_login
            read_password ${4}

            separator

            printf "${G}Установка запущена ...\n${NC}"

            update_server
            upgrade_server
            install_full
            add_user
            conf_nginx
            conf_sphinx
            conf_proftpd
            conf_memcached
            conf_cinemapress
            conf_sysctl
            conf_fail2ban
            conf_iptables
            start_cinemapress
            fail_1
            success_1
            whileStop
        ;;
        2 )
            read_domain ${2}

            separator

            update_cinemapress
            confirm_update_cinemapress ${3}
            whileStop
        ;;
        3 )
            read_domain ${2}
            read_theme ${3}

            separator

            update_theme ${4}
            success_3
            whileStop
        ;;
        4 )
            read_domain ${2}
            read_key ${3}

            separator

            check_db
            import_db
            confirm_import_db ${4}
            whileStop
        ;;
        5 )
            read_domain ${2}
            read_theme ${3}
            read_login
            read_password ${4}
            read_memcached ${5}
            read_sphinx ${6}

            separator

            update_server
            upgrade_server
            install_cinemapress
            add_user
            conf_nginx
            conf_proftpd
            conf_cinemapress
            conf_sysctl
            conf_fail2ban
            conf_iptables
            start_cinemapress
            success_5
            whileStop
        ;;
        6 )
            read_domain ${2}
            read_ip ${3}

            separator

            update_server
            upgrade_server
            install_sphinx
            add_user
            conf_sphinx
            conf_iptables
            success_6
            whileStop
        ;;
        7 )
            read_domain ${2}
            read_ip ${3}

            separator

            update_server
            upgrade_server
            install_memcached
            add_user
            conf_memcached
            conf_iptables
            success_7
            whileStop
        ;;
        8 )
            conf_mass
            start_mass
            success_8
            whileStop
        ;;
        9 )
            import_static
            success_9
            whileStop
        ;;
        10 )
            read_domain ${2}

            separator

            check_domain
            get_ssl
            success_10
            whileStop
        ;;
        11 )
            read_domain ${2}
            read_mega_email ${3}
            read_mega_password ${4}

            separator

            confirm_mega_backup ${5}
            whileStop
        ;;
        * )
            if [ "${1}" = "cron" ]
            then
                case ${2} in
                    searchd )
                        sleep $((RANDOM%30+30)) && searchd --config $(dirname ${0})/sphinx.conf
                    ;;
                    publish )
                        sleep $((RANDOM%120)) && node $(dirname $(dirname ${0}))/lib/CP_cron.js publish
                    ;;
                    abuse )
                        sleep $((RANDOM%60)) && node $(dirname $(dirname ${0}))/lib/CP_cron.js abuse
                    ;;
                    backup )
                        sleep $((RANDOM%60)) && $(dirname ${0})/i 11 "${3}" "${4}" "${5}" 1
                    ;;
                esac
                exit 0
            fi
            option ${1}
        ;;
    esac
done