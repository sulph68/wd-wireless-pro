#!/bin/sh

echo "Untaring overlay package"
tar zxvf /CacheVolume/deploy.tar.gz -C /

echo "Restarting sysctl to start filebrowser"
echo "See: https://filebrowser.org"
systemctl daemon-reload
systemctl enable /etc/systemd/system/filebrowser.service
systemctl start filebrowser.service
echo "Restarting apache2"     
/etc/init.d/S51apache2 restart

echo "Adjusting localtime"
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Singapore /etc/localtime

echo "Securing SMB"
SMB=`cat /etc/samba/smb-global.conf | grep "min protocol"`
if [ ! "$?" = "0" ]; then
	echo "Setting SMB protocol minimum to SMB2"
	echo "min protocol = SMB2" >> /etc/samba/smb-global.conf
else
	echo "Min protocol already set"
	echo "${SMB}"
fi

