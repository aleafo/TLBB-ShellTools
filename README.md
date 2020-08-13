# TLBB-ShellTools

## TLServer-CentOS7x.sh
一键安装TLServer CentOS7.x环境脚本-英文版

使用说明：把 `TLServer CentOS7.x` 文件拖入 Linux `/opt` 下

执行命令：

`cd /opt && chmod +x TLServer CentOS7.x`

`sh TLServer CentOS7.x.sh`


## TLServer-CentOS7x-CHS.sh
一键安装TLServer CentOS7.x环境脚本-中文版

使用说明：把 `TLServer-CentOS7x-CHS.sh` 文件拖入 Linux `/opt` 下

执行命令：

`cd /opt && chmod +x TLServer-CentOS7x-CHS.sh`

`sh TLServer-CentOS7x-CHS.sh`

## TlbbDB-DF.sh
一键删档脚本

使用说明：

`chmod +x TlbbDB-DF.sh`

`sh TlbbDB-DF.sh`

输入数据库密码后等待完成
注：[运行此脚本前建议先停止天龙服务端运行，以免产生脏数据]



# 天龙监听服务+自动备份服务脚本2.1

##[2.1更新]

	1.修正监听引擎时会忽略Server命名的引擎检测
	
	2.美化监听日志，查询日志时层次分明

## 功能说明

初次启动服务端后，创建计划任务：

1).每1分钟扫描一次引擎进程是否存在，如果不存在就立刻重新启动引擎。能保证玩家在第一时间不用找GM也能自动重启引擎。

2).每10分钟自动备份一次数据库，存留备份，以防GM错误操作数据库导致玩家数据丢失等，有回档的余地。

3).每1小时自动备份一次服务端，以防GM或技术错误操作导致服务端文件丢失或者损坏，小心驶得万年船。

## 日志说明：

启动服务端后，日志会自动生成并保存在/home/tlbb目录，无需手动创建。

Db_AutoBackup.log  数据库自动备份日志 

Server_AutoBackup.log  服务端自动备份日志

listenServer.log  监听引擎运行状态日志


## 备份保存的路径

所有备份保存在服务器 /opt 目录下，server_bak为服务端备份目录，db_bak为数据库备份目录。

使用说明：

1).把包内5个sh文件直接覆盖到你端所在的/home/tlbb目录

2).修改AutoBackup-Db.sh第37行、38行

	`mysqldump -uroot -pYOURPASSWORD tlbbdb > /opt/db_bak/${tlbbDbName}`

	`mysqldump -uroot -pYOURPASSWORD web > /opt/db_bak/${webDbName}`

	YOURPASSWORD换成你的数据库密码

2).执行命令：cd /home && chmod -R 777 tlbb

【注】：本套脚本工具已经适用于所有端，不必再担心自己所用的服务器或者端是否支持。