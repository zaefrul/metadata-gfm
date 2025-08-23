#!/bin/bash

# Flutter build configuration script
# This script sets environment variables based on the build flavor

if [ "$1" = "client" ]; then
    export BUNDLE_ID="com.gfm.gems-v3"
    export APP_DISPLAY_NAME="GEMS 2.0"
    export FLAVOR="client"
else
    export BUNDLE_ID="com.gfm.gems"
    export APP_DISPLAY_NAME="GEMS"
    export FLAVOR="classic"
fi

echo "Building with flavor: $FLAVOR"
echo "Bundle ID: $BUNDLE_ID"
echo "App Name: $APP_DISPLAY_NAME"
