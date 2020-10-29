#!/bin/bash
# shell by Wigiesen
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
echo "
+----------------------------------------------------------------------
| CentOS 6.5 天龙服务端环境 安装脚本
+----------------------------------------------------------------------
| Copyright © 2020-2099 心语难诉 版权所有.
+----------------------------------------------------------------------
| 作者: 心语难诉 QQ:437723442
+----------------------------------------------------------------------
"

while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
	read -p "你确定要安装天龙服务端到本系统吗？请选择Y(确定)N(取消): " go;
done

if [ "$go" == 'n' ];then
	exit;
fi

Select_Install_Version(){
    version_arr=(6.5)
    echo "------选择再次确认系统版本(输入版本号,如:6.5)------"
    for i in ${version_arr[@]}
    do
        echo "--------------   $i   --------------"
    done
    echo "-------------------------------------"
    read -p "输入 CentOS 版本号: " version;

    while [ $version != 6.5 ]
    do
        read -p "版本号不正确,请重新输入: " version;
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
    read -p "请输入您需要设置的MySQL数据库密码: " dbpass;
    LimitIsTure=0
    while [[ "$LimitIsTure" == 0 ]]
    do
        if [[ "${#dbpass}" -ge 8 ]];then
            LimitIsTure=1
        else
            read -p "密码必须大于等于8位,请重新输入: " dbpass;
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
    | 天龙服务端架设成功 !!!
    +----------------------------------------------------------
    | 请保存您的MySQL密码: ${dbpass}
    +----------------------------------------------------------
    | 作者: 心语难诉 QQ:437723442
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