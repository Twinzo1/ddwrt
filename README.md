专门为ddwrt使用dogcom新建的repository
将dogcom程序固化进/usr/sbin中
即可在管理→命令中使用下列命令：

#----------------P版-----------------
cat>/tmp/dogcom.conf<<EOF	
server = '10.0.3.2'
pppoe_flag = '\x2f'
keep_alive2_flag = '\xdc'
EOF
dogcom -m pppoe -c /tmp/dogcom.conf -e -d
#------------------------------------------

#-----------------D版----------------------
cat>/tmp/dogcom.conf<<EOF	
server = '58.62.247.115'
username=''
password=''
CONTROLCHECKSTATUS = '\x20'
ADAPTERNUM = '\x04'
host_ip = '172.31.37.194'
IPDOG = '\x01'
host_name = 'DRCOMFUCKER'
PRIMARY_DNS = '202.96.128.166'
dhcp_server = '222.202.171.33'
AUTH_VERSION = '\x7f\x7f'   #maximize version for continuous update
mac = 0xfc15b4ff0125
host_os = 'Linux'
KEEP_ALIVE_VERSION = '\xdc\x02'
EOF
dogcom -m dhcp -c /tmp/dogcom.conf -e -d
#-----------------------------------------


#----------------重连脚本，自动修改mac地址------------------
cat>/tmp/netmac.sh<<EOF	
#!/bin/sh
#Cpyright by Twizo<1282055288@qq.com>

sto(){ 
	stom=\$(nvram get mac_clone_enable  2>/dev/null)
	if [ "\$stom"x = "1"x ]; then
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
#-------------------------------------

*/1 * * * * /tmp/netmac.sh  #一分钟检测一次
*/5 * * * * /tmp/netmac.sh  #五分钟检测一次
*/10 * * * * /tmp/netmac.sh  #十分钟检测一次
#如需使用，请将其中上述一条命令添加到定时任务中
