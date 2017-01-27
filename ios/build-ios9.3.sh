#!/bin/bash
set -x #echo on

## Configuration ##
APP_WORKSPACE="MyApp.xcworkspace"
APP_SCHEME="MyApp-UAT"
APP_CONFIGURATION="Release"
APP_PLIST_PATH="MyApp/MyApp-UAT.plist"

APP_ARCHIVE_PATH="artifacts/myapp-uat"
## /Configuration ##

printenv

/usr/local/bin/pod repo update
/usr/local/bin/pod install

SCRIPTPATH=`pwd`
echo "Current script path: $SCRIPTPATH"

BUILD_NUM=`date +%y.%m.%d_%H.%M`
echo "Building version $BUILD_NUM ..."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUM" $APP_PLIST_PATH 

echo "building app..."
xcodebuild clean archive \
-workspace $APP_WORKSPACE \
-scheme $APP_SCHEME" \
-sdk iphoneos9.3 \
-configuration $APP_CONFIGURATION \
-archivePath $APP_ARCHIVE_PATH
