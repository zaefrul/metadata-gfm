#!/bin/bash

# GEMS Build Script
# This script builds different variants of the GEMS app with the same bundle identifier
# but different configurations to comply with Apple's App Store requirements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build APK
build_apk() {
    local variant=$1
    local build_type=$2
    
    print_info "Building $variant APK ($build_type)..."
    
    if [ "$build_type" = "release" ]; then
        flutter build apk --dart-define=APP_VARIANT=$variant --release
        local output_name="app-$variant-release.apk"
    else
        flutter build apk --dart-define=APP_VARIANT=$variant --debug
        local output_name="app-$variant-debug.apk"
    fi
    
    # Copy and rename the APK
    if [ -f "build/app/outputs/flutter-apk/app-$build_type.apk" ]; then
        cp "build/app/outputs/flutter-apk/app-$build_type.apk" "build/app/outputs/flutter-apk/$output_name"
        print_success "APK built: build/app/outputs/flutter-apk/$output_name"
    else
        print_error "APK build failed for $variant"
        return 1
    fi
}

# Function to build AAB (Android App Bundle)
build_aab() {
    local variant=$1
    
    print_info "Building $variant AAB (release)..."
    
    flutter build appbundle --dart-define=APP_VARIANT=$variant --release
    
    # Copy and rename the AAB
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        cp "build/app/outputs/bundle/release/app-release.aab" "build/app/outputs/bundle/release/app-$variant-release.aab"
        print_success "AAB built: build/app/outputs/bundle/release/app-$variant-release.aab"
    else
        print_error "AAB build failed for $variant"
        return 1
    fi
}

# Function to build iOS IPA
build_ios() {
    local variant=$1
    
    print_info "Building $variant iOS IPA..."
    
    flutter build ios --dart-define=APP_VARIANT=$variant --release
    
    print_success "iOS build completed for $variant. Use Xcode to create archive and IPA."
}

# Function to clean build
clean_build() {
    print_info "Cleaning previous builds..."
    flutter clean
    flutter pub get
    print_success "Clean completed"
}

# Main script logic
case "$1" in
    "classic-apk")
        build_apk "classic" "release"
        ;;
    "client-apk")
        build_apk "client" "release"
        ;;
    "classic-debug")
        build_apk "classic" "debug"
        ;;
    "client-debug")
        build_apk "client" "debug"
        ;;
    "classic-aab")
        build_aab "classic"
        ;;
    "client-aab")
        build_aab "client"
        ;;
    "classic-ios")
        build_ios "classic"
        ;;
    "client-ios")
        build_ios "client"
        ;;
    "all-android")
        print_info "Building all Android variants..."
        build_aab "classic"
        build_aab "client"
        build_apk "classic" "release"
        build_apk "client" "release"
        ;;
    "all-ios")
        print_info "Building all iOS variants..."
        build_ios "classic"
        build_ios "client"
        ;;
    "all")
        print_info "Building all variants for all platforms..."
        build_aab "classic"
        build_aab "client"
        build_apk "classic" "release"
        build_apk "client" "release"
        build_ios "classic"
        build_ios "client"
        ;;
    "clean")
        clean_build
        ;;
    *)
        echo "GEMS Build Script"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  classic-apk     Build Classic variant APK (release)"
        echo "  client-apk      Build Client variant APK (release)"
        echo "  classic-debug   Build Classic variant APK (debug)"
        echo "  client-debug    Build Client variant APK (debug)"
        echo "  classic-aab     Build Classic variant AAB (release)"
        echo "  client-aab      Build Client variant AAB (release)"
        echo "  classic-ios     Build Classic variant iOS"
        echo "  client-ios      Build Client variant iOS"
        echo "  all-android     Build all Android variants"
        echo "  all-ios         Build all iOS variants"
        echo "  all             Build all variants for all platforms"
        echo "  clean           Clean build artifacts"
        echo ""
        echo "Examples:"
        echo "  $0 classic-aab    # Build Classic AAB for Play Store"
        echo "  $0 client-aab     # Build Client AAB for Play Store"
        echo "  $0 all-android    # Build both variants for Android"
        exit 1
        ;;
esac

print_success "Build script completed!"
