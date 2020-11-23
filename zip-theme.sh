#!/bin/sh
cd $(dirname "$0")
cd linhome-shared-themes
/usr/bin/zip -r linhome.zip action_types.xml method_types.xml device_types.xml texts.xml theme.xml images fonts  
rm ../Resources/linhome.zip
cp linhome.zip ../Resources/linhome.zip

