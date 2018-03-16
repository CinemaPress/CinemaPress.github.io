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
	printf "${R}WARNING:${NC} Система работает на Debian 9 x64!\n${NC}"
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
                DOMAIN_=`echo ${DOMAIN} | sed -r "s/[^A-Za-z0-9]/_/g"`
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

read_mirror() {
    printf "${C}-------------------------[ ${Y}URL ЗЕРКАЛА${C} ]--------------------------\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            MIRROR=${1}
            MIRROR=`echo ${MIRROR} | iconv -c -t UTF-8`
            echo ": ${MIRROR}"
        else
            read -e -p ': ' MIRROR
            MIRROR=`echo ${MIRROR} | iconv -c -t UTF-8`
        fi
        if [ "${MIRROR}" != "" ]
        then
            if echo "${MIRROR}" | grep -qE ^\-?[.a-z0-9-]+$
            then
                if [ "${DOMAIN}" = "${MIRROR}" ]
                then
                    printf "${R}WARNING:${NC} Зеркало сайта не может быть таким же, \n"
                    printf "${NC}         как и домен основного сайта! \n"
                else
                    MIRROR_=`echo ${MIRROR} | sed -r "s/[^A-Za-z0-9]/_/g"`
                    AGAIN=no
                fi
            else
                printf "${NC}         Вы ввели - ${MIRROR} \n"
                printf "${R}WARNING:${NC} Допускаются только латинские символы \n"
                printf "${NC}         в нижнем регистре, цифры, точки и дефисы! \n"
            fi
        else
            printf "${R}WARNING:${NC} URL зеркала не может быть пустым. \n"
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
            if [ "${THEME}" = "default" ] || [ "${THEME}" = "hodor" ] || [ "${THEME}" = "sansa" ] || [ "${THEME}" = "robb" ] || [ "${THEME}" = "ramsay" ] || [ "${THEME}" = "tyrion" ] || [ "${THEME}" = "cersei" ] || [ "${THEME}" = "joffrey" ] || [ "${THEME}" = "drogo" ] || [ "${THEME}" = "bran" ] || [ "${THEME}" = "arya" ] || [ "${THEME}" = "mormont" ]
            then
                AGAIN=no
            else
                printf "${R}WARNING:${NC} Нет такой темы. На данный момент существуют темы: hodor, sansa, robb, ramsay, tyrion, cersei, joffrey, drogo, bran, arya и mormont. \n"
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
    if [ "${VER}" != "stretch" ] && [ "${VER}" != "jessie" ]
    then
        apt-get -y -qq autoremove
        apt-get -y -qq install -f
        apt-get -y -qq update
        apt-get -y -qq install aptitude debian-keyring debian-archive-keyring wget curl nano htop sudo lsb-release ca-certificates git-core openssl netcat debconf-utils cron gzip apt-transport-https dirmngr net-tools
        VER=`lsb_release -cs`
        if [ "${VER}" != "stretch" ] && [ "${VER}" != "jessie" ]
        then
            printf "${R}WARNING:${NC} lsb_release не может определить версию системы. \n"
            exit 0
        fi
    fi
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
    apt-get -y -qq install aptitude debian-keyring debian-archive-keyring wget curl nano htop sudo lsb-release ca-certificates git-core openssl netcat debconf-utils cron gzip apt-transport-https dirmngr net-tools
    pre_install
    if [ "${VER}" = "stretch" ]
    then
        VER="jessie"
    fi
    echo -e "deb http://httpredir.debian.org/debian ${VER} main contrib non-free \ndeb-src http://httpredir.debian.org/debian ${VER} main contrib non-free \ndeb http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \ndeb-src http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \ndeb http://security.debian.org/ ${VER}/updates main contrib non-free \ndeb-src http://security.debian.org/ ${VER}/updates main contrib non-free \ndeb http://nginx.org/packages/debian/ `lsb_release -cs` nginx \ndeb-src http://nginx.org/packages/debian/ `lsb_release -cs` nginx" > /etc/apt/sources.list
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
    aptitude -y -q install nginx proftpd-basic openssl mysql-client memcached libltdl7 libodbc1 libpq5 fail2ban iptables-persistent curl libcurl3 logrotate
    # aptitude -y -q install php5-curl php5-cli php5-fpm
    if [ "`lsb_release -cs`" = "stretch" ]
    then
        aptitude -y -q install libmysqlclient18
        sed -i "s/jessie/stable/g" /etc/apt/sources.list
        aptitude -y -q update
        aptitude -y -q install mysql-client
    fi
    NOD=`node -v 2>/dev/null`
    NPM=`npm -v 2>/dev/null`
    if [ "${NOD}" = "" ] || [ "${NPM}" = "" ]
    then
        wget -qO- https://deb.nodesource.com/setup_8.x | bash -
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
    aptitude -y -q install nginx proftpd-basic openssl mysql-client libltdl7 libodbc1 libpq5 fail2ban iptables-persistent curl libcurl3 logrotate
    # aptitude -y -q install php5-curl php5-cli php5-fpm
    if [ "`lsb_release -cs`" = "stretch" ]
    then
        aptitude -y -q install libmysqlclient18
        sed -i "s/jessie/stable/g" /etc/apt/sources.list
        aptitude -y -q update
        aptitude -y -q install mysql-client
    fi
    NOD=`node -v 2>/dev/null`
    NPM=`npm -v 2>/dev/null`
    if [ "${NOD}" = "" ] || [ "${NPM}" = "" ]
    then
        wget -qO- https://deb.nodesource.com/setup_8.x | bash -
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
    aptitude -y -q install memcached fail2ban iptables-persistent logrotate
}

install_sphinx() {
    aptitude -y -q install mysql-client libltdl7 libodbc1 libpq5 fail2ban iptables-persistent logrotate
    if [ "`lsb_release -cs`" = "stretch" ]
    then
        aptitude -y -q install libmysqlclient18
        sed -i "s/jessie/stable/g" /etc/apt/sources.list
        aptitude -y -q update
        aptitude -y -q install mysql-client
    fi
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
    cp -r /home/${DOMAIN}/config/default/* /home/${DOMAIN}/config/production/
    cp -r /home/${DOMAIN}/themes/default/public/admin/favicon.ico /home/${DOMAIN}/
    chown -R ${DOMAIN}:www-data /home/${DOMAIN}/
    cp -r "${0}" /home/${DOMAIN}/config/production/i && chmod +x /home/${DOMAIN}/config/production/i
}

conf_nginx() {
    RND=`randomNum 1 9999`
    NGINX_PORT=$((30000 + RND))
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
    mkdir /etc/nginx/bots.d
    rm -rf /etc/nginx/conf.d/${DOMAIN}.conf
    ln -s /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
    cp /home/${DOMAIN}/config/production/nginx/conf.d/blacklist.conf /etc/nginx/conf.d/blacklist.conf
    cp /home/${DOMAIN}/config/production/nginx/conf.d/rewrite.conf /etc/nginx/conf.d/rewrite.conf
    cp /home/${DOMAIN}/config/production/nginx/bots.d/blockbots.conf /etc/nginx/bots.d/blockbots.conf
    cp /home/${DOMAIN}/config/production/nginx/bots.d/ddos.conf /etc/nginx/bots.d/ddos.conf
    cp /home/${DOMAIN}/config/production/nginx/bots.d/whitelist-domains.conf /etc/nginx/bots.d/whitelist-domains.conf
    cp /home/${DOMAIN}/config/production/nginx/bots.d/whitelist-ips.conf /etc/nginx/bots.d/whitelist-ips.conf
    sed -i "s/:3000/:${NGINX_PORT}/g" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf
    sed -i "s/user  nginx;/user  www-data;/g" /etc/nginx/nginx.conf
    sed -i "s/#gzip/ gzip_disable \"msie6\"; \n gzip_types text\/plain text\/css application\/json application\/x-javascript text\/xml application\/xml application\/xml+rss image\/svg+xml text\/javascript application\/javascript; \n gzip_vary on; \n gzip_proxied any; \n gzip_http_version 1.0; \n gzip/g" /etc/nginx/nginx.conf
    mv /etc/nginx/sites-enabled/default /etc/nginx/default 2>/dev/null
    SNHBS=`grep "server_names_hash_max_size" /etc/nginx/nginx.conf`
    if [ "${SNHBS}" = "" ]
    then
        sed -i "s/http {/http {\n\n    server_names_hash_bucket_size 64;\n    server_names_hash_max_size 4096;\n/g" /etc/nginx/nginx.conf
    fi
    LRZ=`grep "zone=cinemapress" /etc/nginx/nginx.conf`
    if [ "${LRZ}" = "" ]
    then
        sed -i "s/http {/http {\n\n    limit_req_zone \$binary_remote_addr zone=flood:50m rate=90r\/s;\n    limit_conn_zone \$binary_remote_addr zone=addr:50m;\n    limit_req_zone \$binary_remote_addr zone=cinemapress:10m rate=5r\/s;\n/g" /etc/nginx/nginx.conf
    fi
    rm -rf /etc/nginx/nginx_pass_${DOMAIN}
    OPENSSL=`echo "${PASSWD}" | openssl passwd -1 -stdin -salt CP`
    echo "${DOMAIN}:$OPENSSL" >> /etc/nginx/nginx_pass_${DOMAIN}
    service nginx restart
}

conf_sphinx() {
    RND=`randomNum 1 9999`
    SPHINX_PORT=$((40000 + RND))
    RND=`randomNum 1 9999`
    MYSQL_PORT=$((20000 + RND))
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
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
    sed -i "s/example_com/${DOMAIN_}/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
    sed -i "s/example_com/${DOMAIN_}/g" /home/${DOMAIN}/config/xmlpipe2/source.xml
    sed -i "s/:9306/:${MYSQL_PORT}/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
    sed -i "s/:9312/:${SPHINX_PORT}/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
    if [ "`grep \"${DOMAIN}_searchd\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_searchd --------------------------------------" >> /etc/crontab
        echo "@reboot root /home/${DOMAIN}/config/production/i cron searchd >> /home/${DOMAIN}/log/autostart.log 2>&1" >> /etc/crontab
        echo "# ----- ${DOMAIN}_searchd --------------------------------------" >> /etc/crontab
    fi
    if [ "${IP}" != "" ]
    then
        sed -i "s/127\.0\.0\.1:/0\.0\.0\.0:/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
        sed -i "s/= pool/= 0/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
        sed -i "s/= 128M/= 512M/g" /home/${DOMAIN}/config/production/sphinx/sphinx.conf
    fi
    if [ "`lsb_release -cs`" = "jessie" ]
    then
        if [ "`grep \"skip-character-set-client-handshake\" /etc/mysql/my.cnf`" = "" ]
        then
            sed -i "s/\[mysqld\]/\[mysqld\]\ninit_connect='SET collation_connection = utf8_general_ci'\ninit_connect='SET NAMES utf8'\ncharacter-set-server=utf8\ncollation-server=utf8_general_ci\nskip-character-set-client-handshake/g" /etc/mysql/my.cnf
            sed -i "s/\key_buffer/key_buffer_size/g" /etc/mysql/my.cnf
            sed -i "s/\myisam-recover/myisam-recover-options/g" /etc/mysql/my.cnf
            sed -i "s/#max_connections        = 100/max_connections        = 600/g" /etc/mysql/my.cnf
        fi
    else
        mkdir -p /etc/mysql/conf.d/
        if [ -f "/etc/mysql/conf.d/mysqld.cnf" ]
        then
            if [ "`grep \"skip-character-set-client-handshake\" /etc/mysql/conf.d/mysqld.cnf`" = "" ]
            then
                sed -i "s/\[mysqld\]/\[mysqld\]\ninit_connect='SET collation_connection = utf8_general_ci'\ninit_connect='SET NAMES utf8'\ncharacter-set-server=utf8\ncollation-server=utf8_general_ci\nskip-character-set-client-handshake/g" /etc/mysql/conf.d/mysqld.cnf
                sed -i "s/\key_buffer/key_buffer_size/g" /etc/mysql/conf.d/mysqld.cnf
                sed -i "s/\myisam-recover/myisam-recover-options/g" /etc/mysql/conf.d/mysqld.cnf
                sed -i "s/#max_connections        = 100/max_connections        = 600/g" /etc/mysql/conf.d/mysqld.cnf
            fi
        else
            touch /etc/mysql/conf.d/mysqld.cnf
            echo -e "[mysqld]\ninit_connect='SET collation_connection = utf8_general_ci'\ninit_connect='SET NAMES utf8'\ncharacter-set-server=utf8\ncollation-server=utf8_general_ci\nskip-character-set-client-handshake\n\nkey_buffer_size         = 16M\nmyisam-recover-options  = BACKUP\nmax_connections         = 600" >> /etc/mysql/conf.d/mysqld.cnf
        fi
    fi
    indexer --all --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf" || indexer --all --rotate --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf"
    searchd --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf"
    searchd --config "/etc/sphinxsearch/sphinx.conf" --stop
    mv /etc/sphinxsearch/sphinx.conf /etc/sphinxsearch/sphinx.conf.simple
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
    RND=`randomNum 1 9999`
    MEMCACHED_PORT=$((50000 + RND))
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
    sed -i "s/-m 64/-m 128/g" /etc/memcached_${DOMAIN}.conf
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
        sed -E -i "s/\"theme\":\s*\"[a-zA-Z0-9-]*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/default/config.js
        sed -E -i "s/\"theme\":\s*\"[a-zA-Z0-9-]*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/production/config.js
    fi
    if [ "`grep \"${DOMAIN}_cron\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_cron --------------------------------------" >> /etc/crontab
        echo "@hourly root /home/${DOMAIN}/config/production/i cron >> /home/${DOMAIN}/log/autostart.log 2>&1" >> /etc/crontab
        echo "# ----- ${DOMAIN}_cron --------------------------------------" >> /etc/crontab
    fi
    if [ "`grep \"OOM\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- OOM --------------------------------------" >> /etc/crontab
        echo "*/1 * * * * root /home/${DOMAIN}/config/production/i cron oom >> /home/${DOMAIN}/log/autostart.log 2>&1" >> /etc/crontab
        echo "# ----- OOM --------------------------------------" >> /etc/crontab
    fi
    sed -i "s/example_com\"/${DOMAIN_}\"/g" /home/${DOMAIN}/config/production/i
    sed -i "s/_example_com_\"/_${DOMAIN_}_\"/g" /home/${DOMAIN}/config/production/i
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/process.json
    sed -i "s/example_com/${DOMAIN_}/g" /home/${DOMAIN}/process.json
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/production/config.js
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/default/config.js
    sed -i "s/:3000/:${NGINX_PORT}/" /home/${DOMAIN}/config/production/config.js
    sed -i "s/:3000/:${NGINX_PORT}/" /home/${DOMAIN}/config/default/config.js

    if [ "${MYSQL}" != "" ]
    then
        sed -i "s/127\.0\.0\.1:9306/${MYSQL}/" /home/${DOMAIN}/config/production/config.js
        sed -i "s/127\.0\.0\.1:9306/${MYSQL}/" /home/${DOMAIN}/config/default/config.js
    else
        sed -i "s/:9306/:${MYSQL_PORT}/" /home/${DOMAIN}/config/production/config.js
        sed -i "s/:9306/:${MYSQL_PORT}/" /home/${DOMAIN}/config/default/config.js
    fi

    if [ "${MEMCACHED}" != "" ]
    then
        sed -i "s/127\.0\.0\.1:11211/${MEMCACHED}/" /home/${DOMAIN}/config/production/config.js
        sed -i "s/127\.0\.0\.1:11211/${MEMCACHED}/" /home/${DOMAIN}/config/default/config.js
    else
        sed -i "s/:11211/:${MEMCACHED_PORT}/" /home/${DOMAIN}/config/production/config.js
        sed -i "s/:11211/:${MEMCACHED_PORT}/" /home/${DOMAIN}/config/default/config.js
    fi

    cp /home/${DOMAIN}/config/production/config.js /home/${DOMAIN}/config/production/config.prev.js

    wget -qO "geo.tar.gz" http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
    tar xvfz "geo.tar.gz"
    mv GeoLite2*/GeoLite2-City.mmdb /home/${DOMAIN}/files/GeoLite2-City.mmdb
    rm -rf geo.tar.gz GeoLite2-City_*
}

conf_sysctl() {
    if [ ! -f "/etc/sysctl.old.conf" ]
    then
        mv /etc/sysctl.conf /etc/sysctl.old.conf
    fi
    cp /home/${DOMAIN}/config/production/sysctl/sysctl.conf /etc/sysctl.conf
}

conf_fail2ban() {
    if [ ! -f "/etc/fail2ban/jail.old.local" ]
    then
        mv /etc/fail2ban/jail.local /etc/fail2ban/jail.old.local
    fi
    rm -rf /etc/fail2ban/action.d/nginxrepeatoffender.conf
    rm -rf /etc/fail2ban/filter.d/nginxrepeatoffender.conf
    rm -rf /etc/fail2ban/filter.d/nginx-x00.conf
    cp /home/${DOMAIN}/config/production/fail2ban/jail.local \
        /etc/fail2ban/jail.local
    cp /home/${DOMAIN}/config/production/fail2ban/action.d/nginxrepeatoffender.conf \
        /etc/fail2ban/action.d/nginxrepeatoffender.conf
    cp /home/${DOMAIN}/config/production/fail2ban/filter.d/nginxrepeatoffender.conf \
        /etc/fail2ban/filter.d/nginxrepeatoffender.conf
    cp /home/${DOMAIN}/config/production/fail2ban/filter.d/nginx-x00.conf \
        /etc/fail2ban/filter.d/nginx-x00.conf
    service fail2ban restart
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
    sleep 2
    I=`npm list -g --depth=0 | grep "pm2"`
    if [ ! -n "${I}" ]
    then
        sleep 2
        npm install --loglevel=silent --parseable pm2 npm-check-updates -g
        sleep 2
        pm2 startup
        sleep 2
        pm2 install pm2-logrotate
        sleep 2
    fi
    sleep 2
    cd /home/${DOMAIN}/ && \
    CP_ALL="_${DOMAIN_}_" \
    CP_XMLPIPE2="xmlpipe2_${DOMAIN_}" \
    CP_RT="rt_${DOMAIN_}" \
    CP_CONTENT="content_${DOMAIN_}" \
    CP_COMMENT="comment_${DOMAIN_}" \
    CP_USER="user_${DOMAIN_}" \
    node ./config/update/insert_default.js
    sleep 2
    cd /home/${DOMAIN}/ && pm2 start process.json && pm2 save
    hash -r
}

stop_cinemapress() {
    STOP_DOMAIN="${DOMAIN}"
    if [ "${1}" != "" ]; then STOP_DOMAIN="${1}"; fi
    pm2 delete ${STOP_DOMAIN} &> /dev/null
    pm2 save &> /dev/null
    searchd --stop --config "/home/${STOP_DOMAIN}/config/production/sphinx/sphinx.conf"
}

restart_cinemapress() {
    RESTART_DOMAIN="${DOMAIN}"
    if [ "${1}" != "" ]; then RESTART_DOMAIN="${1}"; fi
    check_config ${RESTART_DOMAIN}
    ln -sf /home/${RESTART_DOMAIN}/config/production/nginx/conf.d/nginx.conf \
        /etc/nginx/conf.d/${RESTART_DOMAIN}.conf
    cp /home/${RESTART_DOMAIN}/config/production/nginx/conf.d/blacklist.conf \
        /etc/nginx/conf.d/blacklist.conf
    cp /home/${RESTART_DOMAIN}/config/production/nginx/conf.d/rewrite.conf \
        /etc/nginx/conf.d/rewrite.conf
    cp /home/${RESTART_DOMAIN}/config/production/nginx/bots.d/blockbots.conf \
        /etc/nginx/bots.d/blockbots.conf
    cp /home/${RESTART_DOMAIN}/config/production/nginx/bots.d/ddos.conf \
        /etc/nginx/bots.d/ddos.conf
    cp /home/${RESTART_DOMAIN}/config/production/nginx/bots.d/whitelist-domains.conf \
        /etc/nginx/bots.d/whitelist-domains.conf
    cp /home/${RESTART_DOMAIN}/config/production/nginx/bots.d/whitelist-ips.conf \
        /etc/nginx/bots.d/whitelist-ips.conf
    cp /home/${RESTART_DOMAIN}/config/production/sysctl/sysctl.conf \
        /etc/sysctl.conf
    cp /home/${RESTART_DOMAIN}/config/production/fail2ban/jail.local \
        /etc/fail2ban/jail.local
    cp /home/${RESTART_DOMAIN}/config/production/fail2ban/action.d/nginxrepeatoffender.conf \
        /etc/fail2ban/action.d/nginxrepeatoffender.conf
    cp /home/${RESTART_DOMAIN}/config/production/fail2ban/filter.d/nginxrepeatoffender.conf \
        /etc/fail2ban/filter.d/nginxrepeatoffender.conf
    cp /home/${RESTART_DOMAIN}/config/production/fail2ban/filter.d/nginx-x00.conf \
        /etc/fail2ban/filter.d/nginx-x00.conf
    sleep 2
    service nginx stop
    service nginx start
    service nginx restart
    sleep 2
    service fail2ban stop
    service fail2ban start
    service fail2ban restart
    sleep 2
    service memcached_${RESTART_DOMAIN} stop
    service memcached_${RESTART_DOMAIN} start
    service memcached_${RESTART_DOMAIN} restart
    sleep 2
    searchd --config "/home/${RESTART_DOMAIN}/config/production/sphinx/sphinx.conf"
    sleep 2
    cd /home/${RESTART_DOMAIN}/ && npm i
    sleep 2
    cd /home/${RESTART_DOMAIN}/ && \
    pm2 start process.json && \
    pm2 save
    sleep 2
    node /home/${RESTART_DOMAIN}/config/update/update_cinemapress.js
}

light_restart_cinemapress() {
    RESTART_DOMAIN="${DOMAIN}"
    if [ "${1}" != "" ]; then RESTART_DOMAIN="${1}"; fi
    check_config ${RESTART_DOMAIN}
    pm2 delete ${RESTART_DOMAIN} &> /dev/null
    pm2 save &> /dev/null
    searchd --stop --config "/home/${RESTART_DOMAIN}/config/production/sphinx/sphinx.conf"
    sleep 2
    service nginx stop
    service nginx start
    service nginx restart
    sleep 2
    service fail2ban stop
    service fail2ban start
    service fail2ban restart
    sleep 2
    service memcached_${RESTART_DOMAIN} stop
    service memcached_${RESTART_DOMAIN} start
    service memcached_${RESTART_DOMAIN} restart
    sleep 2
    searchd --config "/home/${RESTART_DOMAIN}/config/production/sphinx/sphinx.conf"
    sleep 2
    cd /home/${RESTART_DOMAIN}/ && \
    pm2 start process.json && \
    pm2 save
}

hard_restart_cinemapress() {
    pm2 delete all &> /dev/null
    pm2 uninstall pm2-logrotate &> /dev/null
    pm2 save &> /dev/null
    pm2 kill &> /dev/null
    rm -rf ~/.pm2/dump.*
    npm remove pm2 -g
    sleep 1
    if [ ! -f "/usr/lib/node_modules/pm2/package.json" ]
    then
        npm install --loglevel=silent --parseable pm2 npm-check-updates -g
        sleep 1
        pm2 startup
        sleep 1
        pm2 install pm2-logrotate
    fi
    service nginx stop
    service nginx start
    service nginx restart
    service fail2ban stop
    service fail2ban start
    service fail2ban restart
    for d in /home/*; do
        if [ -f "$d/process.json" ]
        then
            DOMAIN=`find ${d} -maxdepth 0 -printf "%f"`
            check_config ${DOMAIN}
            searchd --stop --config "${d}/config/production/sphinx/sphinx.conf"
            ln -sf ${d}/config/production/nginx/conf.d/nginx.conf \
                /etc/nginx/conf.d/${DOMAIN}.conf
            cp ${d}/config/production/nginx/conf.d/blacklist.conf \
                /etc/nginx/conf.d/blacklist.conf
            cp ${d}/config/production/nginx/conf.d/rewrite.conf \
                /etc/nginx/conf.d/rewrite.conf
            cp ${d}/config/production/nginx/bots.d/blockbots.conf \
                /etc/nginx/bots.d/blockbots.conf
            cp ${d}/config/production/nginx/bots.d/ddos.conf \
                /etc/nginx/bots.d/ddos.conf
            cp ${d}/config/production/nginx/bots.d/whitelist-domains.conf \
                /etc/nginx/bots.d/whitelist-domains.conf
            cp ${d}/config/production/nginx/bots.d/whitelist-ips.conf \
                /etc/nginx/bots.d/whitelist-ips.conf
            cp ${d}/config/production/sysctl/sysctl.conf \
                /etc/sysctl.conf
            cp ${d}/config/production/fail2ban/jail.local \
                /etc/fail2ban/jail.local
            cp ${d}/config/production/fail2ban/action.d/nginxrepeatoffender.conf \
                /etc/fail2ban/action.d/nginxrepeatoffender.conf
            cp ${d}/config/production/fail2ban/filter.d/nginxrepeatoffender.conf \
                /etc/fail2ban/filter.d/nginxrepeatoffender.conf
            cp ${d}/config/production/fail2ban/filter.d/nginx-x00.conf \
                /etc/fail2ban/filter.d/nginx-x00.conf
            sleep 1
            service memcached_${DOMAIN} stop
            service memcached_${DOMAIN} start
            service memcached_${DOMAIN} restart
            sleep 1
            searchd --config "${d}/config/production/sphinx/sphinx.conf"
            sleep 1
            cd ${d}/ && npm i
            sleep 1
            cd ${d}/ && \
            pm2 start process.json && \
            pm2 save
            sleep 1
            node ${d}/config/update/update_cinemapress.js
        fi
    done
}

check_config() {
    CHECK_DOMAIN="${DOMAIN}"
    if [ "${1}" != "" ]; then CHECK_DOMAIN="${1}"; fi
    if [ -f /home/${CHECK_DOMAIN}/config/production/config.js ] && [ ! -s /home/${CHECK_DOMAIN}/config/production/config.js ]
    then
        if [ -f /home/${CHECK_DOMAIN}/config/production/config.prev.js ] && [ -s /home/${CHECK_DOMAIN}/config/production/config.prev.js ]
        then
            cp /home/${CHECK_DOMAIN}/config/production/config.prev.js \
                /home/${CHECK_DOMAIN}/config/production/config.js
        fi
    fi
    if [ -f /home/${CHECK_DOMAIN}/config/production/modules.js ] && [ ! -s /home/${CHECK_DOMAIN}/config/production/modules.js ]
    then
        if [ -f /home/${CHECK_DOMAIN}/config/production/modules.prev.js ] && [ -s /home/${CHECK_DOMAIN}/config/production/modules.prev.js ]
        then
            cp /home/${CHECK_DOMAIN}/config/production/modules.prev.js \
                /home/${CHECK_DOMAIN}/config/production/modules.js
        fi
    fi
}

conf_mass() {
    FILE_MASS=mass.txt
    if [ ! -f ${FILE_MASS} ]
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
    LNE=1
    while read COMMAND
    do
        if [ "${COMMAND}" = "" ]
        then
            LNE=$((LNE+1))
            continue
        fi
        COM=`echo "${COMMAND}" | grep "# \[SUCCESS]"`
        if [ "${COM}" = "" ]
        then
            sed -i "${LNE}s/\(.*\)/# [SUCCESS] \1/" ${FILE_MASS}
            eval "${COMMAND}"
        fi
        LNE=$((LNE+1))
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

    stop_cinemapress

    cd /home/${DOMAIN}/ && \
    rm -rf `find . | grep -v "backup"`

    rsync -av --stats \
        /home/${DOMAIN}/backup/${B_DIR}/oldCP/* \
        /home/${DOMAIN}

    sleep 5

    chown -R ${DOMAIN}:www-data /home/${DOMAIN}

    restart_cinemapress

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
    DOMAIN_CREATE=`stat -c %y /home/${DOMAIN}/app.js`
    if [ "`date -d "${DOMAIN_CREATE}" +%s`" -lt "`date -d "2017-10-01" +%s`" ];
    then
        printf "\n${NC}"
        printf "${C}------------------------[ ${Y}ПРЕДУПРЕЖДЕНИЕ${C} ]------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----        ${NC}Сайт был создан до 1 октября 2017 года,${C}           ----\n${NC}"
        printf "${C}----    ${NC}потому следует полностью переустановить систему.${C}      ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${NC}  cinemapress.org/article/pereustanovka-sayta-na-cinemapress.html\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi

    mkdir -p /home/${DOMAIN}/backup/${B_DIR}/oldCP
    mkdir -p /home/${DOMAIN}/backup/${B_DIR}/newCP

    git clone \
        https://${GIT_SERVER}/CinemaPress/CinemaPress-ACMS.git \
        /home/${DOMAIN}/backup/${B_DIR}/newCP

    if [ ! -f "/home/${DOMAIN}/backup/${B_DIR}/newCP/app.js" ]; then exit 0; fi;

    stop_cinemapress

    rm -rf /home/${DOMAIN}/node_modules

    rsync -av --stats --exclude backup --remove-source-files \
        /home/${DOMAIN}/* \
        /home/${DOMAIN}/backup/${B_DIR}/oldCP && \
    cd /home/${DOMAIN}/ && \
    find . -depth -type d -empty -delete

    if [ -f "/home/${DOMAIN}/config/default/config.js" ] && [ ! -f "/home/${DOMAIN}/backup/${B_DIR}/oldCP/config/default/config.js" ]
    then
        fail_2
        exit 0
    fi

    rsync -av --stats \
        /home/${DOMAIN}/backup/${B_DIR}/newCP/* \
        /home/${DOMAIN}
    rsync -av --stats --exclude default/public/admin --exclude default/views/admin \
        /home/${DOMAIN}/backup/${B_DIR}/oldCP/themes/* \
        /home/${DOMAIN}/themes
    rsync -av --stats \
        /home/${DOMAIN}/config/default/* \
        /home/${DOMAIN}/config/production
    cp -r /home/${DOMAIN}/themes/default/public/admin/favicon.ico \
        /home/${DOMAIN}/
    rsync -av --stats --exclude default \
        /home/${DOMAIN}/backup/${B_DIR}/oldCP/config/* \
        /home/${DOMAIN}/config

    wget -qO "geo.tar.gz" http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
    tar xvfz "geo.tar.gz"
    mv GeoLite2*/GeoLite2-City.mmdb /home/${DOMAIN}/files/GeoLite2-City.mmdb
    rm -rf geo.tar.gz GeoLite2-City_*

    cd ~/ && \
    cp -r "${0}" /home/${DOMAIN}/config/production/i && \
    chmod +x /home/${DOMAIN}/config/production/i

    sed -i "s/example_com\"/${DOMAIN_}\"/g" /home/${DOMAIN}/config/production/i
    sed -i "s/_example_com_\"/_${DOMAIN_}_\"/g" /home/${DOMAIN}/config/production/i
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/process.json
    sed -i "s/example_com/${DOMAIN_}/g" /home/${DOMAIN}/process.json
    sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/default/config.js

    CURRENT=`grep "CP_ALL" /home/${DOMAIN}/backup/${B_DIR}/oldCP/process.json | sed 's/.*"CP_ALL":\s*"\([a-zA-Z0-9_| -]*\)".*/\1/'`
    sed -E -i "s/\"CP_ALL\":\s*\"[a-zA-Z0-9_| -]*\"/\"CP_ALL\":\"${CURRENT}\"/" /home/${DOMAIN}/process.json
    sed -E -i "s/CP_ALL=\"[a-zA-Z0-9_| -]*\"/CP_ALL=\"${CURRENT}\"/" /home/${DOMAIN}/config/production/i

    ADDRS=`grep "\"addr\"" "/home/${DOMAIN}/backup/${B_DIR}/oldCP/config/default/config.js"`
    NGINX_ADDR=`echo ${ADDRS} | sed 's/.*\"addr\":\s*\"\([0-9a-z.]*:3[0-9]*\)\".*/\1/'`
    sed -i "s/127\.0\.0\.1:3000/${NGINX_ADDR}/" /home/${DOMAIN}/config/default/config.js
    SPHINX_ADDR=`echo ${ADDRS} | sed 's/.*\"addr\":\s*\"\([0-9a-z.]*:2[0-9]*\)\".*/\1/'`
    sed -i "s/127\.0\.0\.1:9306/${SPHINX_ADDR}/" /home/${DOMAIN}/config/default/config.js
    MEMCACHED_ADDR=`echo ${ADDRS} | sed 's/.*\"addr\":\s*\"\([0-9a-z.]*:5[0-9]*\)\".*/\1/'`
    sed -i "s/127\.0\.0\.1:11211/${MEMCACHED_ADDR}/" /home/${DOMAIN}/config/default/config.js

    KEY_=`grep "\"key\"" "/home/${DOMAIN}/backup/${B_DIR}/oldCP/config/default/config.js"`
    KEY=`echo ${KEY_} | sed 's/.*\"key\":\s*\"\([0-9a-zA-Z]\{32\}\|FREE\)\".*/\1/'`
    if [ "${KEY}" != "FREE" ];
    then
        sed -i "s/FREE/${KEY}/" /home/${DOMAIN}/config/default/config.js
    fi
    DATE_=`grep "\"date\"" "/home/${DOMAIN}/backup/${B_DIR}/oldCP/config/default/config.js"`
    DATE=`echo ${DATE_} | sed 's/.*\"date\":\s*\"\([0-9-]\{10\}\|\)\".*/\1/'`
    if [ "${DATE}" != "" ];
    then
        sed -i "s/\"date\": \"\"/\"date\": \"${DATE}\"/" /home/${DOMAIN}/config/default/config.js
    fi

    chown -R ${DOMAIN}:www-data /home/${DOMAIN}

    restart_cinemapress

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
    if [ ! -d /home/${DOMAIN}/themes/${THEME} ]
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

    if [ -d /home/${DOMAIN}/themes/${THEME} ]
    then
        chown -R ${DOMAIN}:www-data /home/${DOMAIN}/themes
        sed -E -i "s/\"theme\":\s*\"[a-zA-Z0-9-]*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/default/config.js
        sed -E -i "s/\"theme\":\s*\"[a-zA-Z0-9-]*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/production/config.js
        echo "Change theme to «${THEME}»" >> /home/${DOMAIN}/restart.server
    fi
}

success_4() {
    wget -q -O /dev/null -o /dev/null "http://database.cinemapress.org/${KEY}/${DOMAIN}?status=SUCCESS"

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

    searchd --stop --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf"

    rm -rf /var/lib/sphinxsearch/data/movies_${DOMAIN_}.*

    cp -R /var/lib/sphinxsearch/old/movies_${DOMAIN_}.* /var/lib/sphinxsearch/data/

    sleep 5

    searchd --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf"

    wget -q -O /dev/null -o /dev/null "http://database.cinemapress.org/${KEY}/${DOMAIN}?status=FAIL"

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
    DOMAIN_CREATE=`stat -c %y /home/${DOMAIN}/app.js`
    if [ "`date -d "${DOMAIN_CREATE}" +%s`" -lt "`date -d "2017-10-01" +%s`" ];
    then
        printf "\n${NC}"
        printf "${C}------------------------[ ${Y}ПРЕДУПРЕЖДЕНИЕ${C} ]------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----        ${NC}Сайт был создан до 1 октября 2017 года,${C}           ----\n${NC}"
        printf "${C}----    ${NC}потому следует полностью переустановить систему.${C}      ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${NC}cinemapress.org/article/pereustanovka-sayta-na-cinemapress.html#update\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
    INDEX_TYPE=`wget -qO- "http://database.cinemapress.org/${KEY}/${DOMAIN}?status=CHECK"`
    sleep 1
    if [ "${INDEX_TYPE}" = "" ]
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
    else
        BAR='##################################################'
        for ((i=1;i<=50;i++));
        do
            if [ "${i}" = "4" ]
            then
                BAR='# Оказавшись перед Путиным, что Вы ему скажете?! #'
            else
                BAR='##################################################'
            fi
            PERCENT=$((2 * i))
            for ((j=1;j<=50;j++));
            do
                echo -ne "\r${PERCENT}% ${BAR:0:$j}"
                sleep .1
            done
            if [ "${i}" = "4" ]
            then
                sleep 5
            fi
            echo -ne "\r${PERCENT}%                                                   "
        done
        printf "\n"
    fi
}

import_db() {
    mkdir -p /var/lib/sphinxsearch/tmp
    rm -rf /var/lib/sphinxsearch/tmp/*

    printf "${G}Загрузка ...\n"

    wget -qO "/var/lib/sphinxsearch/tmp/${KEY}.tar" http://database.cinemapress.org/${KEY}/${DOMAIN} || \
    rm -f "/var/lib/sphinxsearch/tmp/${KEY}.tar"

    if [ -f "/var/lib/sphinxsearch/tmp/${KEY}.tar" ]
    then
        printf "${G}Распаковка ...\n"

        NOW=$(date +%Y-%m-%d)

        searchd --stop --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf" &> /var/lib/sphinxsearch/data/${NOW}.log

        mkdir -p /var/lib/sphinxsearch/data
        mkdir -p /var/lib/sphinxsearch/old

        rm -rf /var/lib/sphinxsearch/old/movies_${DOMAIN_}.*
        cp -R /var/lib/sphinxsearch/data/movies_${DOMAIN_}.* /var/lib/sphinxsearch/old/
        rm -rf /var/lib/sphinxsearch/data/movies_${DOMAIN_}.*
        tar -xf "/var/lib/sphinxsearch/tmp/${KEY}.tar" -C "/var/lib/sphinxsearch/tmp" \
            &> /var/lib/sphinxsearch/data/${NOW}.log

        printf "${G}Установка ...\n"

        sleep 3

        rm -rf "/var/lib/sphinxsearch/tmp/${KEY}.tar"

        FILE_SPA=`find /var/lib/sphinxsearch/tmp/*.* -type f | grep spa`
        FILE_SPD=`find /var/lib/sphinxsearch/tmp/*.* -type f | grep spd`
        FILE_SPI=`find /var/lib/sphinxsearch/tmp/*.* -type f | grep spi`
        FILE_SPS=`find /var/lib/sphinxsearch/tmp/*.* -type f | grep sps`

        if [ -f "${FILE_SPA}" ] && [ -f "${FILE_SPD}" ] && [ -f "${FILE_SPI}" ] && [ -f "${FILE_SPS}" ]
        then
            for file in `find /var/lib/sphinxsearch/tmp/*.* -type f`
            do
                mv ${file} "/var/lib/sphinxsearch/data/movies_${DOMAIN_}.${file##*.}"
            done
        else
            cp -R /var/lib/sphinxsearch/old/movies_${DOMAIN_}.* /var/lib/sphinxsearch/data/
        fi

        printf "${G}Запуск ...\n"

        searchd --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf" &> /var/lib/sphinxsearch/data/${NOW}.log

        CURRENT=`grep "CP_ALL" /home/${DOMAIN}/process.json | sed 's/.*"CP_ALL":\s*"\([a-zA-Z0-9_| -]*\)".*/\1/'`
        sed -E -i "s/\"key\":\s*\"(FREE|[a-zA-Z0-9-]{32})\"/\"key\":\"${KEY}\"/" /home/${DOMAIN}/config/production/config.js
        sed -E -i "s/\"date\":\s*\"[0-9-]*\"/\"date\":\"${NOW}\"/" /home/${DOMAIN}/config/production/config.js
        sed -E -i "s/\"key\":\s*\"(FREE|[a-zA-Z0-9-]{32})\"/\"key\":\"${KEY}\"/" /home/${DOMAIN}/config/default/config.js
        sed -E -i "s/\"date\":\s*\"[0-9-]*\"/\"date\":\"${NOW}\"/" /home/${DOMAIN}/config/default/config.js
        sed -E -i "s/\"CP_ALL\":\s*\"[a-zA-Z0-9_| -]*\"/\"CP_ALL\":\"${CURRENT} | _${INDEX_TYPE}_\"/" /home/${DOMAIN}/process.json
        sed -E -i "s/CP_ALL=\"[a-zA-Z0-9_| -]*\"/CP_ALL=\"${CURRENT} | _${INDEX_TYPE}_\"/" /home/${DOMAIN}/config/production/i

        sleep 2

        cd /home/${DOMAIN} && pm2 reload process.json --update-env

        sleep 3
    else
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
    mkdir -p /var/local/images/poster
    wget http://cinemapress.org/images/web/no-poster.gif -qO /var/local/images/poster/no-poster.gif
    printf "\n${NC}"
    printf "${G}Распаковка в фоновом режиме ...\n"
    printf "${NC}Может занять несколько часов.\n"
    printf "\n${NC}"
    nohup tar -xf /home/images.tar -C /var/local/images >> "/home/images.log" 2>&1 &
}

check_domain() {
    D=`grep -m 1 "server_name" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf | sed 's/.*server_name \([a-zA-Z0-9. -]*\).*/\1/'`
    DO=""
    while IFS=' ' read -ra ADDR; do
        for i in "${ADDR[@]}"; do
            STATUS_HOST=`wget --server-response "http://${i}" 2>&1 | awk '/^  HTTP/{print $2}'`
            if [ "${STATUS_HOST}" != "200" ]
            then
                DO="${i}"
            fi
        done;
    done <<< "${D}"

    if [ "${DO}" != "" ]
    then
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}---- ${NC}Один из доменов недоступен, потому создание сертификата${C}  ----\n${NC}"
        printf "${C}----     ${NC}невозможно. Исправьте ситуацию и заново создайте${C}     ----\n${NC}"
        printf "${C}----             ${NC}сертификат для основного домена.${C}             ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "     ${NC}Основной домен    : ${DOMAIN}\n${NC}"
        printf "     ${NC}Недоступный домен : ${R}${DO}\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
}

get_ssl() {
    wget https://dl.eff.org/certbot-auto -qO /etc/certbot-auto && chmod a+x /etc/certbot-auto
    DS=""
    D=`grep -m 1 "server_name" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf | sed 's/.*server_name \([a-zA-Z0-9. -]*\).*/\1/'`
    while IFS=' ' read -ra ADDR; do for i in "${ADDR[@]}"; do DS="${DS} -d ${i}"; done; done <<< "${D}"
    if [ ! -f "/etc/certbot-auto" ] || [ "${DS}" = "" ]
    then
        printf "\n${NC}"
        printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}---- ${R}Домены, для которых создается сертификат не были найдены.${C}----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}------------------------------------------------------------------\n${NC}"
        printf "\n${NC}"
        exit 0
    fi
    /etc/certbot-auto certonly --non-interactive --webroot --renew-by-default --agree-tos --email support@${DOMAIN} -w /home/${DOMAIN}/ ${DS}
    openssl dhparam -out /etc/letsencrypt/live/${DOMAIN}/dhparam.pem 2048
    sed -i "s/#ssl/ssl/g" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf
    sed -i "s/#listen/listen/g" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf
    sed -i "s/#onlyHTTPS //g" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf
    sed -E -i "s/\"protocol\":\s*\"http:\/\/\"/\"protocol\":\"https:\/\/\"/" /home/${DOMAIN}/config/production/config.js
    if [ "`grep \"renew_ssl\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- renew_ssl --------------------------------------" >> /etc/crontab
        echo "40 5 * * 1 root /etc/certbot-auto renew --quiet --post-hook \"service nginx reload\" >> /var/log/le-renew.log" >> /etc/crontab
        echo "# ----- renew_ssl --------------------------------------" >> /etc/crontab
    fi
    pm2 restart ${DOMAIN}
    service nginx restart
}

create_mega_backup() {
    if [ "`grep \"${DOMAIN}_backup\" /etc/crontab`" = "" ]
    then
        echo -e "\n" >> /etc/crontab
        echo "# ----- ${DOMAIN}_backup --------------------------------------" >> /etc/crontab
        echo "@daily root /home/${DOMAIN}/config/production/i cron backup \"${DOMAIN}\" \"${MEGA_EMAIL}\" \"${MEGA_PASSWD}\" >> /home/${DOMAIN}/log/autostart.log" >> /etc/crontab
        echo "# ----- ${DOMAIN}_backup --------------------------------------" >> /etc/crontab
        update_i
    fi
    MEGA_DAY=$(date +%d)
    MEGA_NOW=$(date +%Y-%m-%d)
    MEGA_DELETE=$(date +%Y-%m-%d -d "30 day ago")
    THEME_NAME=`grep "\"theme\"" /home/${DOMAIN}/config/production/config.js | sed 's/.*"theme":\s*"\([a-zA-Z0-9-]*\)".*/\1/'`
    megarm -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/${MEGA_NOW}/ &> /dev/null
    if [ "${MEGA_DAY}" != "10" ]
    then
        megarm -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/${MEGA_DELETE} &> /dev/null
    fi
    megarm -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/latest &> /dev/null
    sleep 2
    megamkdir -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/ &> /dev/null
    megamkdir -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/${MEGA_NOW}/
    megamkdir -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" /Root/${DOMAIN}/latest/
    sleep 2
    PORT_DOMAIN=`grep "mysql41" /home/${DOMAIN}/config/production/sphinx/sphinx.conf | sed 's/.*:\([0-9]*\):mysql41.*/\1/'`
    echo "FLUSH RTINDEX rt_${DOMAIN_}" | mysql -h0 -P${PORT_DOMAIN}
    echo "FLUSH RTINDEX content_${DOMAIN_}" | mysql -h0 -P${PORT_DOMAIN}
    echo "FLUSH RTINDEX comment_${DOMAIN_}" | mysql -h0 -P${PORT_DOMAIN}
    echo "FLUSH RTINDEX user_${DOMAIN_}" | mysql -h0 -P${PORT_DOMAIN}
    sleep 2
    rm -rf /var/${DOMAIN} && mkdir -p /var/${DOMAIN}
    cd /home/${DOMAIN} && \
    tar -uf /var/${DOMAIN}/config.tar \
        config \
        --exclude=config/update \
        --exclude=config/default \
        --exclude=config/production/i \
        --exclude=config/production/sphinx \
        --exclude=config/production/fail2ban \
        --exclude=config/production/nginx \
        --exclude=config/production/sysctl
    cd /home/${DOMAIN} && \
    tar -uf /var/${DOMAIN}/themes.tar \
        themes/default/public/desktop \
        themes/default/public/mobile \
        themes/default/views/mobile \
        themes/${THEME_NAME}
    sleep 3
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/${MEGA_NOW}/config.tar \
        /var/${DOMAIN}/config.tar
    sleep 1
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/${MEGA_NOW}/themes.tar \
        /var/${DOMAIN}/themes.tar
    sleep 1
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/latest/config.tar \
        /var/${DOMAIN}/config.tar
    sleep 1
    megaput -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" --no-progress \
        --path /Root/${DOMAIN}/latest/themes.tar \
        /var/${DOMAIN}/themes.tar
    sleep 3
    rm -rf /var/${DOMAIN}
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
    rm -rf /var/${DOMAIN} && mkdir -p /var/${DOMAIN}

    stop_cinemapress

    megaget -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" \
        --path /var/${DOMAIN}/ \
        /Root/${DOMAIN}/latest/config.tar
    megaget -u "${MEGA_EMAIL}" -p "${MEGA_PASSWD}" \
        --path /var/${DOMAIN}/ \
        /Root/${DOMAIN}/latest/themes.tar

    cd /home/${DOMAIN} && \
    tar -xf /var/${DOMAIN}/config.tar && \
    tar -xf /var/${DOMAIN}/themes.tar

    chown -R ${DOMAIN}:www-data /home/${DOMAIN}

    restart_cinemapress

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
        sed -i "s/@daily root \/home\/${DOMAIN}\/config\/production\/i cron backup.*//g" /etc/crontab
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
    printf "${C}---- ${G}1)${NC} Запустить автоматическое создание бэкапа каждый день  ${C}----\n${NC}"
    printf "${C}---- ${G}2)${NC} Восстановить сайт из последнего бэкапа                ${C}----\n${NC}"
    printf "${C}---- ${G}3)${NC} Остановить автоматическое создание бэкапа             ${C}----\n${NC}"
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

delete_cinemapress() {
    DELETE_DOMAIN="${DOMAIN}"
    if [ "${1}" != "" ]; then DELETE_DOMAIN="${1}"; fi
    USERID=`id -u ${DELETE_DOMAIN}`
    stop_cinemapress
    service memcached_${DELETE_DOMAIN} stop
    rm -rf /etc/memcached_${DELETE_DOMAIN}.conf
    rm -rf /etc/nginx/conf.d/${DELETE_DOMAIN}.conf;
    rm -rf /etc/nginx/nginx_pass_${DELETE_DOMAIN}
    rm -rf /etc/letsencrypt/live/${DELETE_DOMAIN}
    userdel -r -f ${DELETE_DOMAIN}
    echo "DELETE" | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd --name=${DELETE_DOMAIN} --shell=/bin/false --home=/home/${DELETE_DOMAIN} --uid=${USERID} --gid=${USERID} --delete-user
    if [ "`grep \"${DELETE_DOMAIN}_searchd\" /etc/crontab`" != "" ]
    then
        sed -i "s/# ----- ${DELETE_DOMAIN}_searchd --------------------------------------//g" /etc/crontab
        sed -i "s/@reboot root \/home\/${DELETE_DOMAIN}.*//g" /etc/crontab
    fi
    if [ "`grep \"${DELETE_DOMAIN}_cron\" /etc/crontab`" != "" ]
    then
        sed -i "s/# ----- ${DELETE_DOMAIN}_cron --------------------------------------//g" /etc/crontab
        sed -i "s/@hourly root \/home\/${DELETE_DOMAIN}.*//g" /etc/crontab
    fi
    if [ "`grep \"${DELETE_DOMAIN}_backup\" /etc/crontab`" != "" ]
    then
        sed -i "s/# ----- ${DELETE_DOMAIN}_backup --------------------------------------//g" /etc/crontab
        sed -i "s/@daily root \/home\/${DELETE_DOMAIN}.*//g" /etc/crontab
    fi
    service nginx restart
    sleep 2
    service proftpd restart
    sleep 2
    service fail2ban restart
    printf "\n${NC}"
    printf "${C}---------------------------[ ${Y}УДАЛЕНИЕ${C} ]---------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----           ${G}Ваш сайт успешно удален с сервера.${C}             ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Домен : ${G}${DELETE_DOMAIN}\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
}

update_i() {
    for d in /home/*; do
        if [ -f "$d/config/production/i" ]
        then
            I_DOMAIN=`find ${d} -maxdepth 0 -printf "%f"`
            I_DOMAIN_=`echo ${I_DOMAIN} | sed -r "s/[^A-Za-z0-9]/_/g"`
            cp -r ${0} /home/${I_DOMAIN}/config/production/i && \
            chmod +x /home/${I_DOMAIN}/config/production/i
            I_CURRENT=`grep "CP_ALL" /home/${I_DOMAIN}/process.json | sed 's/.*"CP_ALL":\s*"\([a-zA-Z0-9_| -]*\)".*/\1/'`
            sed -E -i "s/CP_ALL=\"[a-zA-Z0-9_| -]*\"/CP_ALL=\"${I_CURRENT}\"/" /home/${I_DOMAIN}/config/production/i
            sed -i "s/example_com\"/${I_DOMAIN_}\"/g" /home/${I_DOMAIN}/config/production/i
            sed -i "s/_example_com_\"/_${I_DOMAIN_}_\"/g" /home/${I_DOMAIN}/config/production/i
        fi
    done
}

create_mirror() {
    printf "${C}-------------------------[ ${Y}СДЕЛАЙТЕ ВЫБОР${C} ]-----------------------\n${NC}"
    printf "${C}---- ${G}1)${NC} Добавить зеркало к основному домену                   ${C}----\n${NC}"
    printf "${C}---- ${G}2)${NC} Сделать зеркало основным доменом                      ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    if [ ${1} ]
    then
        CM=${1}
        echo "ВАРИАНТ [1-2]: ${CM}"
    else
        read -e -p 'ВАРИАНТ [1-2]: ' CM
        CM=`echo ${CM} | iconv -c -t UTF-8`
    fi
    printf "\n${NC}"
    if [ "${CM}" = "2" ]
    then
        mirror_to_main
    else
        add_mirror
    fi
}

add_mirror() {
    MAIN_DOMAIN="${DOMAIN}"
    if [ "${1}" != "" ]; then MAIN_DOMAIN="${1}"; fi
    MIRROR_DOMAIN="${MIRROR}"
    if [ "${2}" != "" ]; then MIRROR_DOMAIN="${2}"; fi
    D=`grep -m 1 "server_name" /home/${MAIN_DOMAIN}/config/production/nginx/conf.d/nginx.conf | sed 's/.*server_name \([a-zA-Z0-9. -]*\).*/\1/'`
    sed -i "s/server_name \([a-zA-Z0-9. -]*\);/server_name ${D} ${MIRROR_DOMAIN} m\.${MIRROR_DOMAIN};/g" /home/${MAIN_DOMAIN}/config/production/nginx/conf.d/nginx.conf

    if [ "`grep \"#ssl on\" /home/${MAIN_DOMAIN}/config/production/nginx/conf.d/nginx.conf`" = "" ]
    then
        if [ "`grep \"onlyHTTPS\" /home/${MAIN_DOMAIN}/config/production/nginx/conf.d/nginx.conf`" = "" ]
        then
            sed -i "s/server {listen 80;/#onlyHTTPS server {listen 80;/" /home/${MAIN_DOMAIN}/config/production/nginx/conf.d/nginx.conf
        fi

        service nginx restart

        DO=""
        while IFS=' ' read -ra ADDR; do
            for i in "${ADDR[@]}"; do
                STATUS_HOST=`wget --server-response "http://${i}" 2>&1 | awk '/^  HTTP/{print $2}'`
                if [ "${STATUS_HOST}" != "200" ]
                then
                    DO="${i}"
                fi
            done;
        done <<< "${D} ${MIRROR_DOMAIN} m.${MIRROR_DOMAIN}"

        if [ "${DO}" = "" ]
        then
            get_ssl
        else
            printf "\n${NC}"
            printf "${C}-----------------------------[ ${Y}ОШИБКА${C} ]---------------------------\n${NC}"
            printf "${C}----                                                          ${C}----\n${NC}"
            printf "${C}---- ${NC}Один из доменов недоступен, потому создание сертификата${C}  ----\n${NC}"
            printf "${C}----     ${NC}невозможно. Исправьте ситуацию и заново создайте${C}     ----\n${NC}"
            printf "${C}----             ${NC}сертификат для основного домена.${C}             ----\n${NC}"
            printf "${C}----                                                          ${C}----\n${NC}"
            printf "     ${NC}Основной домен    : ${MAIN_DOMAIN}\n${NC}"
            printf "     ${NC}Недоступный домен : ${R}${DO}\n${NC}"
            printf "${C}----                                                          ${C}----\n${NC}"
            printf "${C}------------------------------------------------------------------\n${NC}"
            printf "\n${NC}"
            sed -i "s/#onlyHTTPS //g" /home/${MAIN_DOMAIN}/config/production/nginx/conf.d/nginx.conf
            service nginx restart
        fi
    fi
    printf "\n${NC}"
    printf "${C}------------------------[ ${Y}ЗЕРКАЛО САЙТА${C} ]-------------------------\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}----                 ${NC}Зеркало было добавлено!${C}                  ----\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "     ${NC}Домен   : ${MAIN_DOMAIN}\n${NC}"
    printf "     ${NC}Зеркало : ${MIRROR_DOMAIN}\n${NC}"
    printf "${C}----                                                          ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    service nginx restart
}

mirror_to_main() {
    stop_cinemapress ${DOMAIN}
    stop_cinemapress ${MIRROR}
    mkdir -p /home/${MIRROR}/backup/${B_DIR}/oldCP && \
    rm -rf /home/${DOMAIN}/backup && \
    rm -rf /home/${DOMAIN}/node_modules && \
    cp -r /home/${DOMAIN}/*                            /home/${MIRROR}/backup/${B_DIR}/oldCP/
    cp -r /home/${DOMAIN}/config/comment/*             /home/${MIRROR}/config/comment/
    for f in /home/${MIRROR}/config/comment/content_${DOMAIN_}.*; do
        mv "${f}" "`echo ${f} | sed s/comment_${DOMAIN_}/comment_${MIRROR_}/`"
    done
    cp -r /home/${DOMAIN}/config/content/*             /home/${MIRROR}/config/content/
    for f in /home/${MIRROR}/config/content/content_${DOMAIN_}.*; do
        mv "${f}" "`echo ${f} | sed s/content_${DOMAIN_}/content_${MIRROR_}/`"
    done
    cp -r /home/${DOMAIN}/config/rt/*                  /home/${MIRROR}/config/rt/
    for f in /home/${MIRROR}/config/rt/rt_${DOMAIN_}.*; do
        mv "${f}" "`echo ${f} | sed s/rt_${DOMAIN_}/rt_${MIRROR_}/`"
    done
    cp -r /home/${DOMAIN}/config/user/*                /home/${MIRROR}/config/user/
    for f in /home/${MIRROR}/config/user/user_${DOMAIN_}.*; do
        mv "${f}" "`echo ${f} | sed s/user_${DOMAIN_}/user_${MIRROR_}/`"
    done
    cp -r /home/${DOMAIN}/config/production/config.js /home/${MIRROR}/config/production/config.js
    cp -r /home/${DOMAIN}/config/production/modules.js /home/${MIRROR}/config/production/modules.js
    cp -r /home/${DOMAIN}/themes/default/public/desktop/* /home/${MIRROR}/themes/default/public/desktop/
    cp -r /home/${DOMAIN}/themes/default/public/mobile/* /home/${MIRROR}/themes/default/public/mobile/
    cp -r /home/${DOMAIN}/themes/default/views/mobile/* /home/${MIRROR}/themes/default/views/mobile/
    CURRENT=`grep "CP_ALL" /home/${MIRROR}/process.json | sed 's/.*"CP_ALL":\s*"\([a-zA-Z0-9_| -]*\)".*/\1/'`
    sed -E -i "s/\"CP_ALL\":\s*\"[a-zA-Z0-9_| -]*\"/\"CP_ALL\":\"_${DOMAIN_}_ | ${CURRENT}\"/" /home/${MIRROR}/process.json
    sed -E -i "s/CP_ALL=\"[a-zA-Z0-9_| -]*\"/CP_ALL=\"_${DOMAIN_}_ | ${CURRENT}\"/" /home/${MIRROR}/config/production/i
    delete_cinemapress ${DOMAIN}
    add_mirror ${MIRROR} ${DOMAIN}
    restart_cinemapress ${MIRROR}
}

fail_1() {
    INST_NODE=`dpkg --status nodejs 2>/dev/null | grep "ok installed"`
    INST_NGINX=`dpkg --status nginx 2>/dev/null | grep "ok installed"`
    INST_SPHINX=`dpkg --status sphinxsearch 2>/dev/null | grep "ok installed"`
    if [ "${INST_NODE}" = "" ] || [ "${INST_NGINX}" = "" ] || [ "${INST_SPHINX}" = "" ]
    then
        printf "\n${NC}"
        printf "${C}---------------------------[ ${Y}ОШИБКА${C} ]-----------------------------\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
        printf "${C}----           ${NC}Один или несколько пакетов не были${C}             ----\n${NC}"
        printf "${C}----                ${NC}установлены в системе${C}                     ----\n${NC}"
        printf "${C}----                                                          ${C}----\n${NC}"
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
    printf "${C}---- ${G}12)${NC} Удаление сайта с сервера                             ${C}----\n${NC}"
    printf "${C}---- ${G}13)${NC} Добавление URL-зеркало для сайта                     ${C}----\n${NC}"
    printf "${C}------------------------------------------------------------------\n${NC}"
    printf "\n${NC}"
    AGAIN=yes
    while [ "${AGAIN}" = "yes" ]
    do
        if [ ${1} ]
        then
            OPTION=${1}
            echo "ВАРИАНТ [1-13]: ${OPTION}"
        else
            read -e -p 'ВАРИАНТ [1-13]: ' OPTION
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

randomNum() {
    FLOOR=${1}
    RANGE=${2}
    number=0
    while [ "${number}" -le ${FLOOR} ]
    do
      number=$RANDOM
      let "number %= $RANGE"
    done
    echo ${number}
}

whileStop() {
    WHILE=no
}

B_DIR=$(date '+%d_%m_%Y_%H-%M-%S')

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

            printf "\n${G}Установка запущена ...\n${NC}"

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
            import_db ${4}
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
        12 )
            read_domain ${2}

            separator

            delete_cinemapress
            whileStop
        ;;
        13 )
            read_domain ${2}
            read_mirror ${3}

            separator

            create_mirror
            whileStop
        ;;
        * )
            if [ "${1}" = "cron" ]
            then
                case ${2} in
                    searchd )
                        sleep $((RANDOM%30+30)) && \
                        searchd --config $(dirname ${0})/sphinx/sphinx.conf
                    ;;
                    backup )
                        sleep $((RANDOM%60)) && \
                        $(dirname ${0})/i 11 "${3}" "${4}" "${5}" 1
                    ;;
                    oom )
                        OOM=`dmesg | grep "Out of memory"`
                        ENOMEM=`tail -n100 /root/.pm2/pm2.log | grep "process out of memory\|spawn ENOMEM\|Error caught by domain"`
                        if [ "${OOM}" != "" ]
                        then
                            echo ${OOM}
                            hard_restart_cinemapress
                            reboot
                        elif [ "${ENOMEM}" != "" ]
                        then
                            echo ${ENOMEM}
                            sed -i '/process out of memory/d' /root/.pm2/pm2.log
                            sed -i '/spawn ENOMEM/d' /root/.pm2/pm2.log
                            sed -i '/Error caught by domain/d' /root/.pm2/pm2.log
                            hard_restart_cinemapress
                        fi
                    ;;
                    * )
                        sleep $((RANDOM%120)) && \
                        CP_ALL="_example_com_" \
                        CP_XMLPIPE2="xmlpipe2_example_com" \
                        CP_RT="rt_example_com" \
                        CP_CONTENT="content_example_com" \
                        CP_COMMENT="comment_example_com" \
                        CP_USER="user_example_com" \
                        node $(dirname $(dirname $(dirname ${0})))/lib/CP_cron.js
                    ;;
                esac
                exit 0
            elif [ "${1}" = "stop" ]
            then
                read_domain ${2}

                separator

                stop_cinemapress
                exit 0
            elif [ "${1}" = "start" ]
            then
                read_domain ${2}

                separator

                restart_cinemapress
                exit 0
            elif [ "${1}" = "restart" ]
            then
                read_domain ${2}

                separator

                stop_cinemapress
                restart_cinemapress
                exit 0
            elif [ "${1}" = "light_restart" ]
            then
                read_domain ${2}

                separator

                light_restart_cinemapress
                exit 0
            elif [ "${1}" = "hard_restart" ]
            then
                update_i
                hard_restart_cinemapress
                exit 0
            elif [ "${1}" = "update" ]
            then
                read_domain ${2}

                separator

                update_i
                cd /home/${DOMAIN}/config/update/ && \
                node update_cinemapress.js && \
                CP_ALL="_${DOMAIN_}_" \
                CP_XMLPIPE2="xmlpipe2_${DOMAIN_}" \
                CP_RT="rt_${DOMAIN_}" \
                CP_CONTENT="content_${DOMAIN_}" \
                CP_COMMENT="comment_${DOMAIN_}" \
                CP_USER="user_${DOMAIN_}" \
                node update_collections.js && \
                CP_ALL="_${DOMAIN_}_" \
                CP_XMLPIPE2="xmlpipe2_${DOMAIN_}" \
                CP_RT="rt_${DOMAIN_}" \
                CP_CONTENT="content_${DOMAIN_}" \
                CP_COMMENT="comment_${DOMAIN_}" \
                CP_USER="user_${DOMAIN_}" \
                node update_texts.js
                exit 0
            elif [ "${1}" = "passwd" ]
            then
                read_domain ${2}
                read_password ${3}

                separator

                rm -rf /etc/nginx/nginx_pass_${DOMAIN}
                OPENSSL=`echo "${PASSWD}" | openssl passwd -1 -stdin -salt CP`
                echo "${DOMAIN}:$OPENSSL" >> /etc/nginx/nginx_pass_${DOMAIN}
                service nginx restart
                USERID=`id -u ${DOMAIN}`
                echo ${PASSWD} | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd --name=${DOMAIN} --shell=/bin/false --home=/home/${DOMAIN} --uid=${USERID} --gid=${USERID}
                service proftpd restart
                exit 0
            elif [ "${1}" = "reload" ]
            then
                NAME_CURRENT="${2}"
                ID_CURRENT="${3}"
                while read -r line; do
                    ID_RELOAD=`echo ${line} | sed 's~[^0-9]*\([0-9]*\).*~\1~'`
                    if [ "${ID_RELOAD}" != "${ID_CURRENT}" ]
                    then
                        pm2 reload "${ID_RELOAD}" --force
                    fi
                done <<< "`pm2 show ${NAME_CURRENT} 2>/dev/null | grep 'with id'`";
                exit 0
            elif [ "${1}" = "geo" ]
            then
                read_domain ${2}

                separator

                aptitude -y -q install libpcre++-dev libssl-dev libgeoip-dev libxslt1-dev zlib1g-dev geoip-database libgeoip1
                mkdir -p /usr/share/GeoIP/ && cd /usr/share/GeoIP/ && \
                wget -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz && \
                wget -q http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz
                if [ ! -f "/usr/share/GeoIP/GeoIP.dat.gz" ]; then printf "\n\n${R}ERROR:${NC} Download GeoIP\n\n"; exit 0; fi
                if [ ! -f "/usr/share/GeoIP/GeoIPv6.dat.gz" ]; then printf "\n\n${R}ERROR:${NC} Download GeoIPv6\n\n"; exit 0; fi
                cd /usr/share/GeoIP/ && \
                gunzip -f GeoIP.dat.gz && gunzip -f GeoIPv6.dat.gz && \
                rm -rf GeoIP.dat.gz && rm -rf GeoIPv6.dat.gz && \
                cd ~/

                NGINX_VV=`nginx -v 2>&1`
                NGINX_V=`echo ${NGINX_VV} | grep -o '[0-9.]*'`
                NGINX_CAA=`nginx -V 2>&1`
                NGINX_CA=`echo ${NGINX_CAA} | grep "configure arguments:" | perl -p -ne "s|.*?(--prefix=.*?)(--with-cc-opt\|--with-ld-opt\|--add-module).*|\1|"`
                if [ "`echo ${NGINX_CAA} | grep with-http_geoip_module`" != "" ]; then printf "\n\n${G}Installed${NC}\n\n"; exit 0; fi
                wget -q "http://nginx.org/download/nginx-${NGINX_V}.tar.gz"
                if [ ! -f "nginx-${NGINX_V}.tar.gz" ]; then printf "\n\n${R}ERROR:${NC} Download NGINX\n\n"; exit 0; fi
                tar -xvf "nginx-${NGINX_V}.tar.gz"
                cp /usr/sbin/nginx /usr/sbin/nginx_back
                cd "nginx-${NGINX_V}" && \
                ./configure ${NGINX_CA} --with-http_geoip_module && \
                make && \
                make install
                NGINX_CAA2=`nginx -V 2>&1`
                if [ "`echo ${NGINX_CAA2} | grep with-http_geoip_module`" = "" ]
                then
                    service nginx stop
                    cp /usr/sbin/nginx_back /usr/sbin/nginx
                    service nginx start
                    printf "\n\n${R}ERROR:${NC} Not install\n\n"
                    exit 0
                fi
                GEO=`grep "geoip_country" /etc/nginx/nginx.conf`
                if [ "${GEO}" = "" ]
                then
                    sed -i "s/http {/http {\n\n    geoip_country \/usr\/share\/GeoIP\/GeoIP.dat;\n    map \$geoip_country_code \$allowed_country {\n        default no; RU yes; UA yes; KZ yes; BY yes; DE yes; NL yes; MD yes; US yes; KG yes; LV yes; GB yes; AM yes; IL yes; GE yes; LT yes; UZ yes; AZ yes; EE yes; PL yes; CA yes; FR yes; IT yes; RO yes; ES yes; KR yes; CZ yes; BG yes; GR yes; FI yes; TM yes; TJ yes;\n    }\n/" /etc/nginx/nginx.conf
                fi
                AC=`grep "allowed_country" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf`
                if [ "${AC}" = "" ]
                then
                    sed -i "s/\[::\]:443;/\[::\]:443;\n\n    if (\$allowed_country = '') {set \$allowed_country yes;}\n    if (\$allowed_country = no) {return 444;}/" /home/${DOMAIN}/config/production/nginx/conf.d/nginx.conf
                fi

                light_restart_cinemapress
                exit 0
            elif [ "${1}" = "zero" ]
            then
                read_domain ${2}

                separator

                sed -i "s/xmlpipe_command =.*/xmlpipe_command =/" "/home/${DOMAIN}/config/production/sphinx/sphinx.conf"
                indexer xmlpipe2_${DOMAIN_} --rotate --config "/home/${DOMAIN}/config/production/sphinx/sphinx.conf"
                exit 0
            elif [ "${1}" = "i" ]
            then
                update_i
                exit 0
            elif [ "${1}" = "info" ]
            then
                read_domain ${2}

                separator

                cd /home/${DOMAIN}/ && \
                CP_ALL="_${DOMAIN_}_" \
                CP_XMLPIPE2="xmlpipe2_${DOMAIN_}" \
                CP_RT="rt_${DOMAIN_}" \
                CP_CONTENT="content_${DOMAIN_}" \
                CP_COMMENT="comment_${DOMAIN_}" \
                CP_USER="user_${DOMAIN_}" \
                node ./config/update/update_info.js
                exit 0
            elif [ "${1}" = "insert" ]
            then
                read_domain ${2}

                separator

                cd /home/${DOMAIN}/ && \
                CP_ALL="_${DOMAIN_}_" \
                CP_XMLPIPE2="xmlpipe2_${DOMAIN_}" \
                CP_RT="rt_${DOMAIN_}" \
                CP_CONTENT="content_${DOMAIN_}" \
                CP_COMMENT="comment_${DOMAIN_}" \
                CP_USER="user_${DOMAIN_}" \
                node ./config/update/insert_default.js
                exit 0
            fi
            option ${1}
        ;;
    esac
done