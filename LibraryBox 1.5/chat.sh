#!/bin/sh
echo "To install Chatbox, press enter"
read usrpath

if [ "$usrpath" = "" ]
then
  path="/mnt/usb/librarybox"
else
  path="$usrpath"
fi
echo "Installing Chatbox"

cp $path/piratebox.conf /opt/piratebox/conf/;

echo "Done! Enjoy your LibraryBox!"
