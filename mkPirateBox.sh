#t!/bin/ash
###########################################################################
# mkPirateBox.sh v0.1
# Shell script for installing PirateBox to your fresh OpenWRT router
# (C) 2011, Christiane Ruetten, cr@23bit.net
# see https://github.com/cr/mkPirateBox
# Released under GPLv2, see http://www.gnu.org/licenses/gpl-2.0.html

###########################################################################
# config
pb_ip="192.168.23.1"
pb_wireless_ssid="PirateBox"
pb_hostname="piratebox"
pb_usbdevice="/dev/sda1"
pb_usbmount="/mnt/usb"
pb_filestore="$pb_usbmount/PirateBox/Shared"
pb_extimg="$pb_usbmount/PirateBox/OpenWRT.img"
pb_extmount="/mnt/ext"
pb_swapimg="$pb_usbmount/PirateBox/OpenWRT.swap"
pb_stagefile="/root/.pb_stage"

###########################################################################
# functions

stage() {
	[ -e "$pb_stagefile" ] || echo -n "init" >"$pb_stagefile"
	cat "$pb_stagefile"
}

setstage() {
	if [ "$*" != "done" ]
	then
		echo -n "$*" >"$pb_stagefile"
	else
		rm -f "$pb_stagefile"
	fi
}

###########################################################################
# main

openwrt_version=$(cat /etc/openwrt_version)
openwrt_target="10.03"
if [ "$openwrt_version" != "$openwrt_target" ]
then
	echo "ERROR: This script was designed for OpenWRT 10.03, but you"
	echo "are running $openwrt_version. Sorry, bailing out."
	exit 5
fi

if [ ! -x /root/mkPirateBox.sh ]
then
	cp mkPirateBox.sh /root/mkPirateBox.sh
	chmod +x /root/mkPirateBox.sh
	/root/mkPirateBox.sh
	exit
fi


case $(stage) in

init)
	# check if root password is not set yet
	if grep '^root:!:' /etc/passwd >/dev/null
	then
		echo "Please set a decent root password."
		echo "Next time you log in, you must use ssh."
		while ! passwd
		do
			echo "Try again!"
		done
	fi

	opkg update
	opkg install kmod-usb2 kmod-usb-storage kmod-fs-vfat \
	  kmod-nls-cp437 kmod-nls-cp850 kmod-nls-iso8859-1 \
	  kmod-nls-iso8859-15 block-hotplug kmod-fs-ext3 \
	  kmod-loop e2fsprogs

	# prepare USB storage
	mkdir -p "$pb_usbmount"
	uci set "fstab.@mount[0].target=$pb_usbmount"
	uci set "fstab.@mount[0].device=$pb_usbdevice"
	uci set "fstab.@mount[0].fstype=vfat"
	uci set "fstab.@mount[0].options=rw,sync"
	uci set "fstab.@mount[0].enabled=1"

	# commit all config changes
	uci commit

	# make us persistent for reboot
	mv /etc/rc.local /etc/rc.local_
	echo "/root/mkPirateBox.sh &>/root/mkPirateBox.log" >/etc/rc.local

	setstage withusb
	echo
	echo
	echo "Rebooting the router now to enable USB support and complete the"
	echo -n "second setup phase. Press return to continue..."
	read
	echo "After a while, your router will reboot automatically a second"
	echo "time, but it may take up to several minutes, because about"
	echo "50 MBytes of data is written to your USB disk." 
	echo "You will also find a log of what happened during the second"
	echo "setup stage in /root/mkPirateBox.log."
	echo
	echo "Don't cut your PirateBox's power or network connection, or"
	echo "you will have to start all over again. When the setup has"
	echo "completed you will see a new open wireless network called"
	echo "\"$pb_wireless_ssid\"."
	echo
	echo "When connected wirelessly, point your browser to any website"
	echo "to access the PirateBox share."
	echo
	echo "  PirateBox DNS and hostname: $pb_hostname"
	echo "  PirateBox IP address: $pb_ip"
	echo
	echo "Enjoy!"
	reboot
	sleep 100

	;;
	
withusb)
	# remove reboot persistence
	mv /etc/rc.local_ /etc/rc.local
	setstage stage2
	
	#CAVE: /etc/config/fstab is currently broken
	#Workaround time
	mkdir -p "$pb_usbmount"
	mount "$pb_usbdevice" "$pb_usbmount"
	mount -o loop "$pb_extimg" "$pb_extmount"

	# create an ext3 image file
	dd if=/dev/zero of="$pb_extimg" bs=1M count=16
	echo y | mkfs.ext3 "$pb_extimg"
	mkdir "$pb_extmount"
	uci add fstab mount
	uci set "fstab.@mount[1].target=$pb_extmount"
	uci set "fstab.@mount[1].device=$pb_extimg"
	uci set "fstab.@mount[1].options=loop"
	uci set "fstab.@mount[1].enabled=1"

	# temporarily manually mount ext fs
	mount -o loop "$pb_extimg" "$pb_extmount"

	# prepare opkg, PATH and LD_LIBRARY_PATH for /usr/local
	grep "^dest local" /etc/opkg.conf \
	  || echo "dest local $pb_extmount" >>/etc/opkg.conf
	ln -s "$pb_extmount/usr" /usr/local
	# CAVE: a bug during startup time prevents LD_LIBRARY_PATH
	# and PATH from working as expected. Both are set directly
	# in the init script.
	sed -i 's#export PATH=\(.*\)#export PATH=\1:/usr/local/bin\nexport LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib#' \
	  /etc/profile
	sed -i 's#export PATH=\(.*\)#export PATH=\1:/usr/local/bin\nexport LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib#' \
	  /etc/preinit

	# install python
	opkg update
	opkg -d local install python

	# create a swap file
	dd if=/dev/zero of="$pb_swapimg" bs=1M count=32
	mkswap "$pb_swapimg"
	swapon "$pb_swapimg"
	uci set "fstab.@swap[0].device=$pb_swapimg"
	uci set "fstab.@swap[0].enabled=1"

	# get PirateBox files
	mkdir -p "$pb_filestore"
	cd "$pb_filestore"
	wget http://daviddarts.com/piratebox/piratebox-logo.png
	wget http://daviddarts.com/piratebox/.READ.ME.htm
	wget http://daviddarts.com/piratebox/.BACK.TO.MENU.htm

	sed -i "s#freedrop#$pb_hostname#g" .READ.ME.htm
	sed -i "s#freedrop#$pb_hostname#g" .BACK.TO.MENU.htm
	sed -i "s#FreeDrop#PirateBox#g" .READ.ME.htm
	sed -i "s#FreeDrop#PirateBox#g" .BACK.TO.MENU.htm

	[ -d /usr/local/bin ] || mkdir -p /usr/local/bin
	cd /usr/local/bin
	wget http://daviddarts.com/piratebox/droopy
	chmod +x droopy
	cat <<EOF >/etc/init.d/piratebox
#!/bin/sh /etc/rc.common
START=80

startsrv() {
  # CAVE: /etc/config/fstab is currently broken
  # Ugly workaround time
  mount "$pb_usbdevice" "$pb_usbmount"
  mount -o loop "$pb_extimg" "$pb_extmount"
  swapon "$pb_swapimg"
  # CAVE: more workarounds for early start-up
  export PATH=\$PATH:/usr/local/bin
  export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
  cd "$pb_filestore"
  python /usr/local/bin/droopy \\
    -p "$pb_filestore/piratebox-logo.png" \\
    -d "$pb_filestore" \\
    -m "<p><br><b>1.</b> Learn more about the project \\
        <a href="http://$pb_hostname:8001/.READ.ME.htm"><b>here</b></a>. \\
        <p><b>2.</b> Click above to begin sharing.</p> \\
        <b>3.</b> Browse and download files \\
        <a href="http://$pb_hostname:8001"><b>here</b></a>." &
  python -m SimpleHTTPServer 8001 &
}

start() {
  startsrv &>/dev/null &
}

stop() {
  # CAVE: a bit strong
  killall python
}
EOF
	chmod +x /etc/init.d/piratebox
	# disable web interface, start droopy instead
	/etc/init.d/luci_fixtime disable
	/etc/init.d/luci_dhcp_migrate disable
	/etc/init.d/uhttpd disable
	/etc/init.d/piratebox enable

	# enable full redirect of http traffic
	uci add dhcp domain
	uci set "dhcp.@domain[-1].name=#"
	uci set "dhcp.@domain[-1].ip=$pb_ip"
	uci set "firewall.www=redirect"
	uci set "firewall.www.src=lan"
	uci set "firewall.www.proto=tcp"
	uci set "firewall.www.src_dport=80"
	uci set "firewall.www.dest_ip=$pb_ip"
	uci set "firewall.www.dest_port=80"
	# patch dnsmasq start script to properly handle wildcards
	sed -i 's#^.*\${fqdn\%\.\*}\" ==.*$## ; s#^.*fqdn=\"\$fqdn.*$##' \
	  /etc/init.d/dnsmasq

	# configure network
	uci set "system.@system[0].hostname=$pb_hostname"
	echo "127.0.0.1 $pb_hostname localhost." >/etc/hosts
	echo "$pb_ip $pb_hostname" >>/etc/hosts
	uci set "wireless.radio0.disabled=0"
	uci set "wireless.@wifi-iface[0].ssid=$pb_wireless_ssid"
	uci set "network.lan.ipaddr=$pb_ip"
	
	# commit all config changes
	uci commit

	setstage done
	echo "Rebooting the system one more time."
	reboot
	;;

stage2)
	echo "Looks like there was a hang during the second setup stage."
	echo "See /root/mkPirateBox.log."
	exit 5
	;;

esac

