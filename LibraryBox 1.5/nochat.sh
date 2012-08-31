#!/bin/sh
echo "To remove Chatbox, press enter"
read usrpath

if [ "$usrpath" = "" ]
then
  path="/mnt/usb/librarybox"
else
  path="$usrpath"
fi
echo "Removing Chatbox"

cp $path/piratebox.nochat.conf /opt/piratebox/conf/;
mv /opt/piratebox/conf/piratebox.nochat.conf /opt/piratebox/conf/piratebox.conf

echo "Done! Enjoy your LibraryBox!"
