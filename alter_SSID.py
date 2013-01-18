#!/usr/bin/env python
from os import remove, rename

def alter_SSID():
    """
    customize the SSID for Librarybox
    prompts user for SSID (defaults to "Librarybox - Free Content")
    """
    mySSID = raw_input('Please choose an SSID (press enter for "Librarybox - Free Content"):')

    source = open('/etc/config/wireless', 'r')
    destination = open('/etc/config/wireless_new', 'w')
	
    for line in source:
        if (line.find('PirateBox - Share Freely') > -1):
            if mySSID:
                line = line.replace('PirateBox - Share Freely', mySSID)
            else:
                line = line.replace('PirateBox - Share Freely', 'LibraryBox - Free Content!')
        destination.write(line)

    source.close()
    destination.close()
    
    rename('/etc/config/wireless', '/etc/config/wireless_old')
    rename('/etc/config/wireless_new', '/etc/config/wireless')

if __name__=="__main__":
	alter_SSID()