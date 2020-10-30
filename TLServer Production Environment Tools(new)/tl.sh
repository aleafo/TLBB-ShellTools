#!/bin/bash
# shell by XYNS(Wigiesen)
# GitHub: https://github.com/Wigiesen
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

# 检查系统是否是64bit
is64bit=$(getconf LONG_BIT)
if [ "${is64bit}" != '64' ];then
	echo -e "\033[41mSorry, the script currently does not support CentOS 32-bit system, please use CentOS 64-bit system.\033[0m"
    exit;
fi


echo -e "\033[44;30m+-----------------------------------------------------+\033[0m"
echo -e "\033[44;30m| TLBB Tools 1.0  GitHub: https://github.com/Wigiesen |\033[0m"
echo -e "\033[44;30m|        \033[0m\033[41mAuthor: Wigiesen(xyns) QQ:437723442\033[0m\033[44;30m          |\033[0m"
echo -e "\033[44;30m+-----------------------------------------------------+\033[0m"
echo -e "\033[44;30m| (1).Install TLBB Server for CentOS6.5               |\033[0m"
echo -e "\033[44;30m| (2).Install TLBB Server for CentOS7.x               |\033[0m"
echo -e "\033[44;30m| (3).Install TLBB Server for CentOS8.0               |\033[0m"
echo -e "\033[44;30m| (4).Clean Data for TLBB Database                    |\033[0m"
echo -e "\033[44;30m| (5).Exit                                            |\033[0m"
echo -e "\033[44;30m+-----------------------------------------------------+\033[0m"

# CentOS6.5安装
Install_65(){
    # if [ ! -f "/opt/tlbbfor6.5.tar.gz" ];then
    #     wget -P /opt http://xxxx.com/res/tlbbfor6.5.tar.gz
    # fi
    tar -zxvf /opt/tlbbfor6.5.tar.gz -C /opt
    # 设置数据库密码
    read -p "Please enter mysql password for root: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "Password must be longer than 8 characters, Please re-enter : " dbpass;
        fi
    done

    # 进入安装目录
    cd /opt

    # 数据库安装
    yum -y install mysql-server
    service mysqld restart

    # 数据库权限相关操作
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO root@'%.%.%.%' IDENTIFIED BY '${dbpass}';"
    mysql -e "use mysql;update user set Password=PASSWORD('${dbpass}') where User='root';";
    mysql -e "create database tlbbdb;";
    mysql -e "create database web;";
    mysql -e "flush privileges;";

    # 导入纯净数据库
    mysql -uroot -p${dbpass} tlbbdb < tlbbdb.sql
    mysql -uroot -p${dbpass} web < web.sql

    # 安装依赖组件
    sudo yum -y install glibc.i686 libstdc++-4.4.7-4.el6.i686

    # 安装ODBC与ODBC相关依赖组件
    rpm -ivh 6.5_unixODBC.rpm --nodeps --force
    rpm -ivh 6.5_mysql-odbc.rpm --nodeps --force

    # 解压ODBC支持库到use/lib目录
    tar -zxvf 6.5_myodbc.tar.gz -C /usr/lib

    # 安装libstdc组件
    sudo yum -y install libstdc++
    sudo yum -y install libstdc++.so.6

    # ODBC配置
    tar zvxf Config.tar.gz -C /etc
    sed -i "s/^\(Password        = \).*/\1${dbpass}/" /etc/odbc.ini

    #重启MYSQL并打开自动重启
    /etc/rc.d/init.d/mysqld restart
    chkconfig mysqld on

    #清空操作记录
    cat /dev/null >/root/.mysql_history
    cat /dev/null >/root/.bash_history
}

# CentOS7.x安装
Install_7x(){
    # if [ ! -f "/opt/tlbbfor7x.tar.gz" ];then
    #     wget -P /opt http://xxxx.com/res/tlbbfor7x.tar.gz
    # fi
    tar zxvf /opt/tlbbfor7x.tar.gz -C /opt
    # 设置数据库密码
    read -p "Please enter mysql password for root: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "Password must be longer than 8 characters, Please re-enter : " dbpass;
        fi
    done

    # 进入安装目录
    cd /opt

    # 数据库安装
    yum -y remove mysql-libs
    tar zxvf MySQL.tar.gz
    rpm -ivh mysql-client.rpm
    rpm -ivh mysql-server.rpm

    # 数据库权限相关操作
    mysql -e "grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option;";
    mysql -e "use mysql;update user set password=password('${dbpass}') where user='root';";
    mysql -e "create database tlbbdb;";
    mysql -e "create database web;";
    mysql -e "flush privileges;";
    # 导入纯净数据库
    mysql -uroot -p${dbpass} tlbbdb < tlbbdb.sql
    mysql -uroot -p${dbpass} web < web.sql

    # 安装依赖组件
    yum -y install glibc.i686 libstdc++-4.4.7-4.el6.i686 libstdc++.so.6

    # 安装ODBC与ODBC相关依赖组件
    tar zxvf lib.tar.gz
    rpm -ivh unixODBC-libs.rpm
    rpm -ivh unixODBC-2.2.11.rpm
    rpm -ivh libtool-ltdl.rpm
    rpm -ivh unixODBC-devel.rpm --nodeps --force

    # 安装MYSQL ODBC驱动
    tar zxvf ODBC.tar.gz
    ln -s /usr/lib64/libz.so.1 /usr/lib/lib
    rpm -ivh mysql-odbc.rpm --nodeps

    # ODBC配置
    tar zvxf Config.tar.gz -C /etc
    chmod 644 /etc/my.cnf
    sed -i "s/^\(Password        = \).*/\1${dbpass}/" /etc/odbc.ini

    # 解压ODBC支持库到use/lib目录
    tar zvxf odbc.tar.gz -C /usr/lib
}

# CentOS8.x安装
Install_8x(){
    # if [ ! -f "/opt/tlbbfor7x.tar.gz" ];then
    #     wget -P /opt http://xxxx.com/res/tlbbfor7x.tar.gz
    # fi
    tar zxvf /opt/tlbbfor7x.tar.gz -C /opt
    # 设置数据库密码
    read -p "Please enter mysql password for root: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "Password must be longer than 8 characters, Please re-enter : " dbpass;
        fi
    done

    # 进入安装目录
    cd /opt

    # 数据库安装
    yum -y remove mysql-libs
    tar zxvf MySQL.tar.gz
    dnf install -y ncurses-compat-libs
    dnf install -y libnsl

    rpm -ivh mysql-client.rpm
    rpm -ivh mysql-server.rpm

    # 数据库权限相关操作
    mysql -e "grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option;";
    mysql -e "use mysql;update user set password=password('${dbpass}') where user='root';";
    mysql -e "create database tlbbdb;";
    mysql -e "create database web;";
    mysql -e "flush privileges;";
    # 导入纯净数据库
    mysql -uroot -p${dbpass} tlbbdb < tlbbdb.sql
    mysql -uroot -p${dbpass} web < web.sql

    # 安装依赖组件
    yum -y install glibc.i686 libstdc++ libstdc++.so.6

    # 安装ODBC与ODBC相关依赖组件
    tar zxvf lib.tar.gz
    yum -y install libcrypt.so.1
    yum -y install libnsl.so.1
    rpm -ivh unixODBC-libs.rpm
    rpm -ivh unixODBC-2.2.11.rpm
    rpm -ivh libtool-ltdl.rpm
    rpm -ivh unixODBC-devel.rpm --nodeps --force

    # 安装MYSQL ODBC驱动
    tar zxvf ODBC.tar.gz
    ln -s /usr/lib64/libz.so.1 /usr/lib/lib
    yum -y install libz.so.1
    rpm -ivh mysql-odbc.rpm --nodeps

    # ODBC配置
    tar zvxf Config.tar.gz -C /etc
    chmod 644 /etc/my.cnf
    sed -i "s/^\(Password        = \).*/\1${dbpass}/" /etc/odbc.ini

    # 解压ODBC支持库到use/lib目录
    tar zvxf odbc.tar.gz -C /usr/lib
}


# 检查MySQL是否已经开启
checkMySQLStatus(){
    port=`netstat -nlt|grep 3306|wc -l`
    if [ $port -ne 1 ];then
        echo -e "\033[41mMySQL Service is not running!\033[0m"
        exit;
    fi
}

# 清理流程
cleanDatabase(){
    # if [ ! -f "/opt/db.tar.gz" ];then
    #     wget -P /opt "http://xxxx.com/res/db.tar.gz"
    # fi
    tar zxvf /opt/db.tar.gz -C /opt
    read -p "Please enter mysql password for root: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [ ! -n "${dbpass}" ];then
            read -p "Password must be input, Please re-enter : " dbpass;
        else
            LimitIsTure=1
        fi
    done
    echo "Please wait....."
    mysql -uroot -p${dbpass} -e "drop database if exists tlbbdb; drop database if exists web;";
    mysql -uroot -p${dbpass} -e "create database tlbbdb; create database web;";
    mysql -uroot -p${dbpass} tlbbdb < ./tlbbdb.sql
    mysql -uroot -p${dbpass} web < ./web.sql
    echo -e "+----------------------------------------------------------------------"
    echo -e "| TLBB Database is cleaned successfully !!!"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| Injoy ！"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| Author: \033[41mWigiesen(xyns) QQ:437723442\033[0m"
    echo -e "+----------------------------------------------------------------------"
}


# 安装成功提示
InstallSuccessfully(){
    echo -e "+----------------------------------------------------------------------"
    echo -e "| TLBB Service installed successfully !!!"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| Please save your MySQL database password: \033[44;30m${dbpass}\033[0m"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| Author: \033[41mWigiesen(xyns) QQ:437723442\033[0m"
    echo -e "+----------------------------------------------------------------------"
}

# 清空所有资源包
cleanAll(){
    cd /opt && find . -mindepth 1 -maxdepth 1 '!' -name tl.sh -exec rm -rf {} + || true
}

# 系统版本号
SYS_VERSION=$(cat /etc/redhat-release | grep -oE "([0-9])\.([0-9])")

# 选择使用的功能
go=6
while [ ! -n "$go" ] || [ $go -gt 5 ] || [ $go -lt 1 ]
do
	read -p "Please enter the function number: " go;
done

# 功能分发
if [ "$go" = "1" ]; then
    if [ "$SYS_VERSION" != "6.5" ]; then
        # supports 6.5
        echo -e "\033[41mYour system is not CentOS 6.5 64bit\033[0m"
        exit;
    fi
    # 进入安装流程
    Install_65
    InstallSuccessfully
    cleanAll
elif [ "$go" = "2" ]; then
    # supports 7.2 7.3 7.6 7.7 7.8
    if [[ $SYS_VERSION < 7.2 ]] || [[ $SYS_VERSION > 7.8 ]]; then
        echo -e "\033[41mSorry, CentOS7.x currently only supports: 7.2 7.3 7.6 7.7 7.8\033[0m"
        exit;
    fi
    # 进入安装流程
    Install_7x
    InstallSuccessfully
    cleanAll
elif [ "$go" = "3" ]; then
    # supports 8.0
    if [ "$SYS_VERSION" != "8.0" ]; then
        echo -e "\033[41mYour system is not CentOS 8.0 64bit\033[0m"
        exit;
    fi
    # 进入安装流程
    Install_8x
    InstallSuccessfully
    cleanAll
elif [ "$go" = "4" ]; then
    checkMySQLStatus
    cleanDatabase
    cleanAll
elif [ "$go" = "5" ]; then
    echo -e "\033[42;37mExit successfully. To use again, enter the command: sh tl.sh\033[0m" 
    exit;
else
    echo -e "\033[42;37mExit successfully. To use again, enter the command: sh tl.sh\033[0m" 
    exit;
fi
