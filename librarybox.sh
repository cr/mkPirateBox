#!/bin/sh
echo "Press return, or enter custom path to /librarybox"
read usrpath

if [ "$usrpath" = "" ]
then
  path="/mnt/usb/librarybox"
else
  path="$usrpath"
fi
echo "Making your LibraryBox..."

cp $path/droopy /opt/piratebox/bin/;
chmod ug+x /opt/piratebox/bin/droopy
cp $path/hosts /opt/piratebox/conf/;
cp $path/index.html /opt/piratebox/chat/;
cp $path/piratebox-logo-small.png /opt/piratebox/src/;
cp $path/piratebox-logo.png /opt/piratebox/src/;
cp $path/piratebox-logo.png /opt/piratebox/share/;
cp $path/piratebox.conf /opt/piratebox/conf/;
cp $path/READ.ME.htm /opt/piratebox/share/; 
mv /opt/piratebox/share/READ.ME.htm /opt/piratebox/share/.READ.ME.htm;
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
python /mnt/usb/librarybox/alter_SSID.py

echo "Done! Enjoy your LibraryBox!"
