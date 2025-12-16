#!/bin/bash

# Incontext TestFlight Build Script
# This script builds your iOS app and prepares it for TestFlight upload

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Incontext iOS TestFlight Build Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Get project directory (script is in scripts/ subdirectory)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo -e "${GREEN}✓${NC} Project directory: $PROJECT_DIR"
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}✗ Error: pubspec.yaml not found. Are you in the project root?${NC}"
    exit 1
fi

# Read current version
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo -e "${BLUE}Current version:${NC} $CURRENT_VERSION"
echo ""

# Ask if user wants to increment build number
echo -e "${YELLOW}Do you want to increment the build number?${NC}"
echo "Current: $CURRENT_VERSION"
read -p "Increment build number? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Extract version and build number
    VERSION_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f1)
    BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)
    NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
    NEW_VERSION="${VERSION_NUMBER}+${NEW_BUILD_NUMBER}"

    echo -e "${YELLOW}Updating version to:${NC} $NEW_VERSION"

    # Update pubspec.yaml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    else
        # Linux
        sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    fi

    echo -e "${GREEN}✓${NC} Version updated to $NEW_VERSION"
    echo ""
fi

# Step 1: Clean
echo ""
echo -e "${BLUE}[1/4] Cleaning Flutter build...${NC}"
flutter clean
echo -e "${GREEN}✓${NC} Clean complete"

# Step 2: Get dependencies
echo ""
echo -e "${BLUE}[2/4] Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓${NC} Dependencies updated"

# Step 3: Run code generation (if needed)
if grep -q "build_runner" pubspec.yaml; then
    echo ""
    echo -e "${BLUE}[3/4] Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✓${NC} Code generation complete"
else
    echo ""
    echo -e "${BLUE}[3/4] Skipping code generation (not needed)${NC}"
fi

# Step 4: Build IPA
echo ""
echo -e "${BLUE}[4/4] Building iOS IPA...${NC}"
echo -e "${YELLOW}This may take 5-15 minutes...${NC}"
echo ""

flutter build ipa --release

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓${NC} IPA build complete!"

    # Find the IPA file
    IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n 1)

    if [ -n "$IPA_PATH" ]; then
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}   BUILD SUCCESSFUL!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BLUE}IPA Location:${NC}"
        echo "  $IPA_PATH"
        echo ""
        echo -e "${BLUE}IPA Size:${NC}"
        du -h "$IPA_PATH"
        echo ""
        echo -e "${BLUE}Next Steps:${NC}"
        echo "  1. Open Transporter app on your Mac"
        echo "  2. Sign in with your Apple ID"
        echo "  3. Drag and drop the IPA file above"
        echo "  4. Click 'Deliver' to upload to App Store Connect"
        echo ""
        echo -e "${BLUE}Or use command line:${NC}"
        echo "  xcrun altool --upload-app -f '$IPA_PATH' \\"
        echo "    -t ios -u YOUR_APPLE_ID@email.com"
        echo ""
        echo -e "${YELLOW}Note: You'll need your app-specific password for the command line upload${NC}"
        echo "      Get it at: https://appleid.apple.com/account/manage"
        echo ""

        # Optionally open in Finder
        read -p "Open IPA location in Finder? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$(dirname "$IPA_PATH")"
        fi

        # Optionally open Transporter
        read -p "Open Transporter app? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open -a "Transporter"
        fi
    fi
else
    echo -e "${RED}✗ IPA build failed${NC}"
    exit 1
fi

# Step 5: Summary
echo ""
echo -e "${BLUE}Build Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓${NC} Bundle ID: com.in-context"
FINAL_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo -e "${GREEN}✓${NC} Version: $FINAL_VERSION"
echo ""

echo -e "${YELLOW}Remember:${NC}"
echo "  • Each upload needs a unique build number"
echo "  • First TestFlight build may take 24-48 hours for review"
echo "  • Subsequent builds are usually available in 5-30 minutes"
echo ""

echo -e "${GREEN}Build script complete! 🎉${NC}"
echo ""
