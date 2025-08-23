#!/bin/bash

# iOS Flavor Configuration
# Usage: ./ios_build.sh [classic|client] [debug|release|ipa]

FLAVOR=${1:-classic}
BUILD_TYPE=${2:-ipa}

if [ "$FLAVOR" = "client" ]; then
    BUNDLE_ID="com.gfm.gems.v3"
    APP_NAME="GEMS 2.0"
else
    BUNDLE_ID="com.gfm.gems"
    APP_NAME="GEMS"
fi

echo "Building iOS with:"
echo "Flavor: $FLAVOR"
echo "Bundle ID: $BUNDLE_ID"
echo "App Name: $APP_NAME"
echo "Build Type: $BUILD_TYPE"
echo ""

# Build commands using dart-define
case $BUILD_TYPE in
    "debug")
        flutter build ios --debug \
            --dart-define=FLAVOR=$FLAVOR \
            --dart-define=BUNDLE_ID=$BUNDLE_ID \
            --dart-define=APP_DISPLAY_NAME="$APP_NAME"
        ;;
    "release")
        flutter build ios --release \
            --dart-define=FLAVOR=$FLAVOR \
            --dart-define=BUNDLE_ID=$BUNDLE_ID \
            --dart-define=APP_DISPLAY_NAME="$APP_NAME"
        ;;
    "ipa")
        flutter build ipa \
            --dart-define=FLAVOR=$FLAVOR \
            --dart-define=BUNDLE_ID=$BUNDLE_ID \
            --dart-define=APP_DISPLAY_NAME="$APP_NAME"
        ;;
    *)
        echo "Invalid build type. Use: debug, release, or ipa"
        exit 1
        ;;
esac
