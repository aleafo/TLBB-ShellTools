#!/bin/bash
# shell by XYNS(Wigiesen)
# GitHub: https://github.com/Wigiesen
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

# 检查系统是否是64bit
is64bit=$(getconf LONG_BIT)
if [ "${is64bit}" != '64' ];then
	echo -e "\033[41m抱歉, 当前脚本不支持CentOS 32位系统, 请使用CentOS 64位系统.\033[0m"
    exit;
fi

echo -e "\033[44;30m+---------------------------------------------------------+\033[0m"
echo -e "\033[44;30m| TLBB服务端工具 1.0  GitHub: https://github.com/Wigiesen |\033[0m"
echo -e "\033[44;30m|               \033[0m\033[41m作者: 心语难诉 QQ:437723442\033[0m\033[44;30m               |\033[0m"
echo -e "\033[44;30m+---------------------------------------------------------+\033[0m"
echo -e "\033[44;30m| (1).安装TLBB服务器环境到 CentOS 6.5                     |\033[0m"
echo -e "\033[44;30m| (2).安装TLBB服务器环境到 CentOS 7.x                     |\033[0m"
echo -e "\033[44;30m| (3).安装TLBB服务器环境到 CentOS 8.x                     |\033[0m"
echo -e "\033[44;30m| (4).执行删档                                            |\033[0m"
echo -e "\033[44;30m| (5).退出                                                |\033[0m"
echo -e "\033[44;30m+---------------------------------------------------------+\033[0m"

# CentOS6.5安装
Install_65(){
    # if [ ! -f "/opt/tlbbfor6.5.tar.gz" ];then
    #     wget -P /opt http://xxxx.com/res/tlbbfor6.5.tar.gz
    # fi
    tar -zxvf /opt/tlbbfor6.5.tar.gz -C /opt
    # 设置数据库密码
    read -p "请输入您需要设置的MySQL数据库密码: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "密码必须大于等于8位,请重新输入 : " dbpass;
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
    sudo yum -y install glibc.i686 libstdc++ libstdc++.so.6

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
    read -p "请输入您需要设置的MySQL数据库密码: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "密码必须大于等于8位,请重新输入 : " dbpass;
        fi
    done

    # 进入安装目录
    cd /opt

    # 数据库安装
    yum -y remove mysql-libs
    tar zxvf MySQL.tar.gz
    rpm -ivh mysql-client.rpm --nodeps --force
    rpm -ivh mysql-server.rpm --nodeps --force

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
    sudo yum -y install glibc.i686 libstdc++ libstdc++.so.6

    # 安装ODBC与ODBC相关依赖组件
    tar zxvf lib.tar.gz
    rpm -ivh unixODBC-libs.rpm --nodeps --force
    rpm -ivh unixODBC-2.2.11.rpm --nodeps --force
    rpm -ivh libtool-ltdl.rpm --nodeps --force
    rpm -ivh unixODBC-devel.rpm --nodeps --force

    # 安装MYSQL ODBC驱动
    tar zxvf ODBC.tar.gz
    ln -s /usr/lib64/libz.so.1 /usr/lib/lib
    rpm -ivh mysql-odbc.rpm --nodeps --force

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
    read -p "请输入您需要设置的MySQL数据库密码: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "密码必须大于等于8位,请重新输入 : " dbpass;
        fi
    done

    # 进入安装目录
    cd /opt

    # 数据库安装
    yum -y remove mysql-libs
    tar zxvf MySQL.tar.gz
    dnf install -y ncurses-compat-libs
    dnf install -y libnsl

    rpm -ivh mysql-client.rpm --nodeps --force
    rpm -ivh mysql-server.rpm --nodeps --force

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
    sudo yum -y install glibc.i686 libstdc++ libstdc++.so.6

    # 安装ODBC与ODBC相关依赖组件
    tar zxvf lib.tar.gz
    yum -y install libcrypt.so.1
    yum -y install libnsl.so.1
    rpm -ivh unixODBC-libs.rpm --nodeps --force
    rpm -ivh unixODBC-2.2.11.rpm --nodeps --force
    rpm -ivh libtool-ltdl.rpm --nodeps --force
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
        echo -e "\033[41mMySQL数据库并未启动!\033[0m"
        exit;
    fi
}

# 清理流程
cleanDatabase(){
    # if [ ! -f "/opt/db.tar.gz" ];then
    #     wget -P /opt "http://xxxx.com/res/db.tar.gz"
    # fi
    tar zxvf /opt/db.tar.gz -C /opt
    read -p "请输入您需要设置的MySQL数据库密码: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [ ! -n "${dbpass}" ];then
            read -p "密码不允许为空!请重新输入 : " dbpass;
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
    echo -e "| TLBB 数据库删档成功 !!!"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| 作者: \033[41m心语难诉 QQ:437723442\033[0m"
    echo -e "+----------------------------------------------------------------------"
}


# 安装成功提示
InstallSuccessfully(){
    echo -e "+----------------------------------------------------------------------"
    echo -e "| TLBB 服务端环境安装成功 !!!"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| 请牢记您设置的MySQL数据库密码: \033[44;30m${dbpass}\033[0m"
    echo -e "+----------------------------------------------------------------------"
    echo -e "| 作者: \033[41m心语难诉 QQ:437723442\033[0m"
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
	read -p "请输入功能编号 : " go;
done

# 功能分发
if [ "$go" = "1" ]; then
    if [ "$SYS_VERSION" != "6.5" ]; then
        # supports 6.5
        echo -e "\033[41m抱歉, 您当前的系统并不是 CentOS 6.5 64位\033[0m"
        exit;
    fi
    # 进入安装流程
    Install_65
    InstallSuccessfully
    cleanAll
elif [ "$go" = "2" ]; then
    # supports 7.2 7.3 7.6 7.7 7.8
    if [[ $SYS_VERSION < 7.2 ]] || [[ $SYS_VERSION > 7.8 ]]; then
        echo -e "\033[41m抱歉, CentOS7.x版本目前只支持以下版本: 7.2 7.3 7.6 7.7 7.8\033[0m"
        exit;
    fi
    # 进入安装流程
    Install_7x
    InstallSuccessfully
    cleanAll
elif [ "$go" = "3" ]; then
    # supports 8.0 8.2
    if [[ $SYS_VERSION < 8.0 ]] || [[ $SYS_VERSION > 8.2 ]]; then
        echo -e "\033[41m抱歉, CentOS8.x版本目前只支持以下版本: 8.0 8.1 8.2\033[0m"
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
    echo -e "\033[42;37m退出成功, 下次使用时请直接执行 sh tl.sh 即可重新进入.\033[0m" 
    exit;
else
    echo -e "\033[42;37m退出成功, 下次使用时请直接执行 sh tl.sh 即可重新进入.\033[0m" 
    exit;
fi
