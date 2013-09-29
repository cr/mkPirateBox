#!/bin/sh
echo "Press return, or enter custom path to /librarybox"
read usrpath

if [ "$usrpath" = "" ]
then
  path="/mnt/usb/librarybox"
else
  path="$usrpath"
fi
echo "Patching iOS7 issue..."

cp $path/droopy /opt/piratebox/bin/;

echo "Done! Enjoy your LibraryBox!"
