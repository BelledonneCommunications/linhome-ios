
#!/bin/sh
if [ "$#" -ne 1 ] ; then
  echo "Usage: $0 build directory of linphone sdk for ios: Ex : ./copy-local-sdk.sh ~/Desktop/belledonne-communications/master-gitosis/linphone-sdk/ioslindoor/" >&2
  exit 1
fi

cp $1/linphone-sdk.podspec linphone-sdk/
cp -r $1/linphone-sdk/apple-darwin linphone-sdk/linphone-sdk
#find linphone-sdk -name "*.framework" -exec echo -n "{}/" \; -exec basename {} .framework  \;  > libs && while read lib; do  xcrun bitcode_strip -r $lib  -o $lib; done < libs && rm libs
