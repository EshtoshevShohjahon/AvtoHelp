#!/bin/bash

# AvtoHelp - APK Build Script
# Builds release APK for Android

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   AvtoHelp - APK Builder${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed!${NC}"
    exit 1
fi

cd mobile

# Clean previous builds
echo -e "${YELLOW}[1/4] Cleaning previous builds...${NC}"
flutter clean
echo -e "${GREEN}✅ Clean complete${NC}\n"

# Get dependencies
echo -e "${YELLOW}[2/4] Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}\n"

# Build APK
echo -e "${YELLOW}[3/4] Building APK...${NC}"
echo -e "${BLUE}This may take a few minutes...${NC}\n"
flutter build apk --release
echo -e "${GREEN}✅ APK built successfully${NC}\n"

# Get APK path
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
APK_SIZE=$(du -h $APK_PATH | cut -f1)

# Display info
echo -e "${YELLOW}[4/4] APK Information${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ APK Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Location:${NC} ${GREEN}mobile/$APK_PATH${NC}"
echo -e "${BLUE}Size:${NC} ${GREEN}$APK_SIZE${NC}\n"

echo -e "${YELLOW}Install on device:${NC}"
echo -e "  ${GREEN}adb install mobile/$APK_PATH${NC}\n"

echo -e "${YELLOW}Or copy to:${NC}"
echo -e "  ${GREEN}$(pwd)/$APK_PATH${NC}\n"

cd ..

echo -e "${BLUE}Happy testing! 📱${NC}\n"
