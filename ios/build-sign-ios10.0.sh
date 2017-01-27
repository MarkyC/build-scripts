#!/bin/bash
set -x #echo on

## Configuration ##
APP_WORKSPACE="MyApp.xcworkspace"
APP_SCHEME="MyApp-UAT"
APP_CONFIGURATION="Release"
APP_PLIST_PATH="MyApp/MyApp-UAT.plist"

APP_ARCHIVE_PATH="artifacts/myapp-uat"
APP_IPA_PATH="artifacts/ipa"

APP_CODE_SIGN_IDENTITY="iPhone Distribution: My Company Inc - Enterprise"
APP_PROVISIONING_PROFILE="1234abcd-fg56-78hi-jk90-12345lmnop"
APP_SIGNING_KEY="A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0"
## /Configuration ##

SCRIPTPATH=`pwd`
echo "Current script path: $SCRIPTPATH"

echo "latest commit:"
git log --name-status HEAD^..HEAD

printenv

echo "updating pods..."
/usr/local/bin/pod repo update
/usr/local/bin/pod install

BUILD_NUM=`date +%y.%m.%d_%H.%M`
echo "Building version $BUILD_NUM ..."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUM" $APP_PLIST_PATH

echo "building app..."
xcodebuild clean archive \
-workspace $APP_WORKSPACE \
-scheme $APP_SCHEME \
-sdk iphoneos10.0 \
-configuration $APP_CONFIGURATION \
-archivePath $APP_ARCHIVE_PATH \
CODE_SIGN_IDENTITY=$APP_CODE_SIGN_IDENTITY \
PROVISIONING_PROFILE=$APP_PROVISIONING_PROFILE

echo "creating ipa..."
mkdir -p $APP_IPA_PATH
xcrun -sdk iphoneos9.3 \
PackageApplication \
"$SCRIPTPATH/$APP_ARCHIVE_PATH.xcarchive/Products/Applications/$APP_SCHEME.app" \
-o "$SCRIPTPATH/$APP_IPA_PATH/$APP_SCHEME.ipa" \
--sign $APP_SIGNING_KEY

echo "creating ipa..."
mkdir -p artifacts/ipa/
$DEVELOPER_DIR/usr/bin/xcodebuild -exportArchive \
-archivePath "$SCRIPTPATH/$APP_ARCHIVE_PATH.xcarchive" \
-exportOptionsPlist $APP_PLIST_PATH \
-exportPath "$SCRIPTPATH/$APP_IPA_PATH/$APP_SCHEME.ipa" \
-exportProvisioningProfile $APP_CODE_SIGN_IDENTITY

echo "zipping dSYMs..."
zip $APP_IPA_PATH/dSYMs.zip $APP_ARCHIVE_PATH.xcarchive/dSYMs/$APP_SCHEME.app.dSYM

