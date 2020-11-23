#!/bin/sh
cd $(dirname "$0")
export DESC=`git describe --abbrev=0`
export COUNT=`git rev-list $DESC..HEAD --count`
export HASH=`git rev-parse --short HEAD`
if [ $COUNT -eq 0 ] ; then 
	export GIT_VERSION=$DESC
else
	export GIT_VERSION=$DESC.$COUNT+$HASH
fi
echo $GIT_VERSION

# xcrun agvtool new-marketing-version
# xcrun agvtool bump

