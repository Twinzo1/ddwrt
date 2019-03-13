专门为ddwrt使用dogcom新建的repository

在启动时先拨号，联网然后下载dogcom程序和脚本。

使用教程：

将以下命令保存在启动指令之中，将dogcom.txt内容保存在自定义指令中，其余内容请查看dogcom.txt

wget https://raw.githubusercontent.com/Twinzo1/ddwrt/master/dogcom_ar71xx --no-check-certificate

#下载dogcom

wget https://raw.githubusercontent.com/Twinzo1/ddwrt/master/dogcom.sh --no-check-certificate

#下载dogcom.sh

mv dogcom_ar71xx /tmp/dogcom

#移动并重命名dogcom

mv dogcom.sh /tmp/dogcom.sh

#移动dogcom.sh

chmod 755 /tmp/dogcom

chmod 755 /tmp/dogcom.sh




