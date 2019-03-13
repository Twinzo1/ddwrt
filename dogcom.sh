#!/bin/sh
#Cpyright by Twizo<1282055288@qq.com>
#此脚本是面向ddwrt的，如果支持jffs2请开启jffs2，将其保存在jffs文件夹中。
#如果不支持，请将其及程序固化在固件中。
#使用教程：先使用wireshark抓包，然后去 分析心跳包，然后将配置文件填写在对应版本位置

#------------开启dogcom客户端-------------
#nvram set dogcom_enable="1"   #开启dogcom，请注释下一行(加#号)
#nvram set dogcom_enable="0"   #关闭dogcom，请注释上一行(加#号)

#--------------选择drcom版本--------------
nvram set dogcom_version="P"  #P版，如果使用D版，请在前面加上#号
#nvram set dogcom_version="D"  #D版(需去掉前面#号)，如果使用P版，请在前面加上#号
#-----------------------------------------


#---------断线重连脚本，默认生成----------
nvram set net_check="1"   #启动脚本，请注释下一行(加#号)
#nvram set net_check="0"   #关闭脚本，请注释上一行(加#号)
#网络连接失败时，该脚本可以自动更改mac地址
#------------开启重连脚本命令-------------
*/1 * * * * /tmp/netmac.sh  #一分钟检测一次
*/5 * * * * /tmp/netmac.sh  #五分钟检测一次
*/10 * * * * /tmp/netmac.sh  #十分钟检测一次
#如需开启，请将其中上述一条命令添加到定时任务中
netsh(){
	cat>/tmp/netmac.sh<<EOF	
#!/bin/sh
#Cpyright by Twizo<1282055288@qq.com>

sto(){ 
	stom=$(nvram get mac_clone_enable  2>/dev/null)
	if [ "$stom"x = "1"x ]; then
		nvram set mac_clone_enable="0"
	else
		nvram set mac_clone_enable="1"
	fi
	nvram commit
}
check()
{
	tries=0
	echo --- my_watchdog start ---
	while [[ $tries -lt 2 ]]
	do
			if /bin/ping -c 1 8.8.8.8 >/dev/null
			then
				echo --- exit ---
				exit 0
			fi
			tries=$((tries+1))
			sleep 3
	done
	
	sto     //修改mac地址
	sleep 5
	killall pppd
	/usr/sbin/pppd file /tmp/ppp/options.pppoe >/dev/null
}

check
EOF
chmod 755 /tmp/netmac.sh
}
#---------断线重连脚本到此为止------------

#-----------drcom配置正式开始-------------
start()
{
	curdir=/tmp/dogcom.conf
	touch $curdir
	tmp_server="server= '$(nvram get dogcom_server )'"
	
	enable=$(nvram get dogcom_enable 2>/dev/null)
	version=$(nvram get dogcom_version 2>/dev/null)
	net_check=$(nvram get net_check 2>/dev/null)
	if [ "$dogcom_enable"x != "1"x ]; then
		killall dogcom
		return
	fi
	
	if [ "$net_check"x = "1"x ]; then
		netmac
	else
		rm -f /tmp/netmac.sh
	
	if [ "$version" == "P" ]; then
		mode='pppoe'
		tmp_pppoe_flag="pppoe_flag='$(nvram get dogcom_pppoe_flag )'"
		tmp_keep_alive2_flag="keep_alive2_flag='$(nvram get dogcom_keep_alive2_flag )'"
		#---------------P版---------------		
		echo $tmp_server > $curdir

		echo "$tmp_pppoe_flag" >> $curdir
		echo "$tmp_keep_alive2_flag"  >> $curdir
	else
		mode='dhcp'
		tmp_username="username = '$(nvram get dogcom_username)'"
		tmp_password="password = '$(nvram get dogcom_password)'"			
		tmp_host_name="host_name = '$(nvram get dogcom_host_name)'"
		tmp_host_os="host_os = '$(nvram get dogcom_host_os)'"
		tmp_host_ip="host_ip = '$(nvram get dogcom_host_ip)'"
		tmp_dhcp_server="dhcp_server = '$(nvram get dogcom_dhcp_server)'"
		tmp_mac="mac = '$(nvram get dogcom_mac)'"
		tmp_PRIMARY_DNS="PRIMARY_DNS = '$(nvram get dogcom_PRIMARY_DNS)'"
		tmp_AUTH_VERSION="AUTH_VERSION = '$(nvram get dogcom_AUTH_VERSION)'"
		tmp_KEEP_ALIVE_VERSION="KEEP_ALIVE_VERSION = '$(nvram get dogcom_KEEP_ALIVE_VERSION)'"
		tmp_CONTROLCHECKSTATUS="CONTROLCHECKSTATUS = '$(nvram get dogcom_CONTROLCHECKSTATUS)'"
		tmp_ADAPTERNUM="ADAPTERNUM = '$(nvram get dogcom_ADAPTERNUM)'"
		tmp_IPDOG="IPDOG = '$(nvram get dogcom_IPDOG)'"
		#---------------D版---------------
		echo $tmp_server > $curdir 
		
		echo $tmp_username >> $curdir
		echo $tmp_password >> $curdir
		echo $tmp_host_name >> $curdir
		echo $tmp_host_os >> $curdir
		echo $tmp_host_ip >> $curdir
		echo $tmp_dhcp_server >> $curdir
		echo $tmp_mac >> $curdir
		echo $tmp_PRIMARY_DNS >> $curdir
		echo $tmp_AUTH_VERSION >> $curdir
		echo $tmp_KEEP_ALIVE_VERSION >> $curdir
		echo $tmp_CONTROLCHECKSTATUS >> $curdir
		echo $tmp_ADAPTERNUM >> $curdir
		echo $tmp_IPDOG >> $curdir
	fi
	
	/tmp/dogcom -m $mode -c /tmp/dogcom.conf -e -d 
}

start

