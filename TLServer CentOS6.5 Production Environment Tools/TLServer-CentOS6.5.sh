#!/bin/bash
# shell by Wigiesen
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
echo "
+----------------------------------------------------------------------
| TLBB Service for CentOS 6.5 install shell
+----------------------------------------------------------------------
| Copyright © 2020-2099 Wigiesen All rights reserved.
+----------------------------------------------------------------------
| Author: Wigiesen(xyns) QQ:437723442
+----------------------------------------------------------------------
"

while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
	read -p "Do you want to install TLBB Service for CentOS 6.5 to your Server now?(y/n): " go;
done

if [ "$go" == 'n' ];then
	exit;
fi

Select_Install_Version(){
    version_arr=(6.5)
    echo "---------Please select version ------"
    for i in ${version_arr[@]}
    do
        echo "--------------   $i   --------------"
    done
    echo "-------------------------------------"
    read -p "Select CentOS version: " version;

    while [ $version != 6.5 ]
    do
        read -p "Please enter the correct CentOS version: " version;
    done
}

downloadPack(){
    # if [ ! -f "/opt/tlbbfor6.5.tar.gz" ];then
    #     wget -P /opt http://tlbbres.xinyu19.com/tlbbfor6.5.tar.gz
    # fi
    tar -zxvf /opt/tlbbfor6.5.tar.gz -C /opt
}

installTlbbService(){
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

claerSetupLib(){
    rm -rvf *
    echo "
    +----------------------------------------------------------
    | TLBB Service for CentOS 6.5 installed successfully !!!
    +----------------------------------------------------------
    | Please save your MySQL database password: ${dbpass}
    +----------------------------------------------------------
    | Author: Wigiesen(xyns) QQ:437723442
    +----------------------------------------------------------
    "
}

# 选择系统版本
Select_Install_Version
# 下载Lib
downloadPack
# 安装TLBB Service
installTlbbService
# 清理安装包
claerSetupLib