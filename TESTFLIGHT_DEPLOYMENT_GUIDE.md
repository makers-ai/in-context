# TestFlight Deployment Guide for InContext

This guide will walk you through publishing your Flutter app to TestFlight today.

## Prerequisites Checklist

- [ ] Active Apple Developer Account ($99/year)
- [ ] Xcode installed on your Mac
- [ ] Flutter SDK properly configured
- [ ] Valid Apple ID with Developer access
- [ ] Mac with macOS (required for iOS development)

## Step 1: Prepare Your App Information

Before starting, gather the following information:

- **App Name**: InContext (or your preferred name)
- **Bundle ID**: (e.g., `com.yourcompany.incontext`)
- **App Description**: Brief description of your app
- **App Category**: Choose from App Store categories
- **Privacy Policy URL**: (if required)
- **App Icon**: 1024x1024px PNG (no alpha channel)

## Step 2: Configure App Store Connect

### 2.1 Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with your Apple Developer account
3. Click **My Apps** → **+ (plus icon)** → **New App**
4. Fill in the required information:
   - **Platform**: iOS
   - **Name**: InContext (must be unique on App Store)
   - **Primary Language**: English
   - **Bundle ID**: Create/select your bundle ID (e.g., `com.yourname.incontext`)
   - **SKU**: A unique identifier (e.g., `incontext-001`)
   - **User Access**: Full Access
5. Click **Create**

### 2.2 Set Up Test Information

1. In your new app, go to **TestFlight** tab
2. Under **Test Information**, fill in:
   - **Beta App Description**: What testers should know
   - **Feedback Email**: Your email for tester feedback
   - **Privacy Policy URL**: (if applicable)
3. Click **Save**

## Step 3: Configure Your Xcode Project

### 3.1 Open Xcode Project

```bash
cd /Users/cristian/Documents/tech/incontext
open ios/Runner.xcworkspace
```

**IMPORTANT**: Always open `.xcworkspace`, NOT `.xcodeproj` when using CocoaPods!

### 3.2 Configure Project Settings in Xcode

1. In Xcode, select **Runner** in the project navigator (left sidebar)
2. Select **Runner** target under TARGETS
3. Go to **Signing & Capabilities** tab:
   - **Automatically manage signing**: Check this box
   - **Team**: Select your Apple Developer team
   - **Bundle Identifier**: Set to match App Store Connect (e.g., `com.yourname.incontext`)

4. Go to **General** tab:
   - **Display Name**: InContext
   - **Version**: 1.0.0 (should match pubspec.yaml)
   - **Build**: 1 (should match pubspec.yaml)
   - **Deployment Target**: iOS 12.0 or higher (check minimum requirement)

5. Verify **Identity** section:
   - Check that Bundle Identifier matches App Store Connect

### 3.3 Update Info.plist Permissions

Your app uses several permissions. Verify they're all in `ios/Runner/Info.plist`:

1. In Xcode, open `Runner/Info.plist`
2. Ensure all required permissions have descriptions:
   - Camera access (for image_picker)
   - Photo library access (for image_picker)
   - Microphone access (for audio recording)

## Step 4: Prepare the Build

### 4.1 Clean and Get Dependencies

```bash
cd /Users/cristian/Documents/tech/incontext

# Clean previous builds
~/flutter/bin/flutter clean

# Get dependencies
~/flutter/bin/flutter pub get

# Install iOS dependencies
cd ios && pod install && cd ..
```

### 4.2 Run Analysis (Optional but Recommended)

```bash
# Check for issues
~/flutter/bin/flutter analyze

# Format code
~/flutter/bin/dart format .
```

## Step 5: Build and Archive for App Store

### 5.1 Build iOS Release

```bash
cd /Users/cristian/Documents/tech/incontext

# Build iOS app in release mode
~/flutter/bin/flutter build ios --release --no-codesign
```

This command:
- Builds your Flutter app for iOS
- Uses release mode (optimized)
- Skips code signing (we'll do this in Xcode)

### 5.2 Create Archive in Xcode

1. Open Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode menu bar:
   - Select **Product** → **Destination** → **Any iOS Device (arm64)**
   - DO NOT select a simulator

3. Create the archive:
   - Select **Product** → **Archive**
   - Wait for the build to complete (may take 5-10 minutes)
   - If you get errors, check:
     - Signing is configured correctly
     - Team is selected
     - Bundle ID matches App Store Connect

4. When complete, the **Organizer** window will open automatically

## Step 6: Upload to App Store Connect

### 6.1 Distribute Archive

In the Xcode Organizer window:

1. Select your archive (should be the topmost one)
2. Click **Distribute App**
3. Select **App Store Connect**
4. Click **Next**
5. Select **Upload**
6. Click **Next**
7. Configure distribution options (use defaults):
   - **App Thinning**: All compatible device variants
   - **Rebuild from Bitcode**: Yes
   - **Include symbols**: Yes
8. Click **Next**
9. Review signing settings:
   - **Automatically manage signing**: Selected
   - Verify your team is selected
10. Click **Upload**
11. Wait for upload to complete (may take 10-30 minutes depending on internet speed)
12. You'll see a success message when done

## Step 7: Configure TestFlight

### 7.1 Wait for Processing

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** tab
4. Under **iOS Builds**, you should see your build with status "Processing"
5. Wait for processing to complete (typically 10-30 minutes, can take up to 24 hours)
6. You'll receive an email when processing is complete

### 7.2 Provide Export Compliance Information

When processing completes:

1. Your build will show a yellow warning: **Missing Compliance**
2. Click on your build
3. Answer the export compliance questions:
   - "Does your app use encryption?"
     - If YES (you're using HTTPS): Select YES
     - Then answer: "Is the encryption exempt?" → Select YES for standard HTTPS
   - Most apps can claim exemption
4. Click **Start Internal Testing** (if you see this option)

### 7.3 Add Internal Testers

1. In TestFlight tab, go to **Internal Testing** section
2. Click on **Default Internal Group** or create a new group
3. Click **+ (plus icon)** next to Testers
4. Add testers (must have access to App Store Connect)
5. Enable the build for this group
6. Testers will receive email invitations

### 7.4 Add External Testers (Optional)

For users outside your organization:

1. Go to **External Testing** section
2. Click **+ (plus icon)** to create a test group
3. Add testers by email
4. Select your build
5. Provide test information:
   - What to test
   - Feedback email
6. Submit for Beta App Review (required for external testing)
   - This can take 24-48 hours for Apple review
   - Not required for internal testing

## Step 8: Install TestFlight on Test Devices

### 8.1 Testers Install TestFlight App

1. Testers download **TestFlight** from App Store
2. Testers open invitation email and click **View in TestFlight**
3. Or use the public link/redemption code you provide

### 8.2 Install Your App

1. Open TestFlight app
2. Your app appears under **Apps Available to Test**
3. Tap **Install**
4. Start testing!

## Troubleshooting Common Issues

### Issue: "No accounts with App Store Connect access"

**Solution**:
- Ensure you're signed in with the correct Apple ID in Xcode
- Go to Xcode → Preferences → Accounts
- Add your Apple Developer account if not present

### Issue: "Failed to register bundle identifier"

**Solution**:
- Bundle ID must match exactly between Xcode and App Store Connect
- Check for typos
- Ensure Bundle ID is not already taken

### Issue: "Provisioning profile doesn't match"

**Solution**:
- Use "Automatically manage signing" in Xcode
- Clean build folder: Product → Clean Build Folder
- Delete derived data: Xcode → Preferences → Locations → Derived Data → Delete

### Issue: Build stuck in "Processing" for hours

**Solution**:
- Wait up to 24 hours (unusual but possible)
- Check your email for any issues from Apple
- Contact Apple Developer Support if > 24 hours

### Issue: "Missing Compliance" warning

**Solution**:
- Click on the build in TestFlight
- Answer export compliance questions
- Most apps using standard HTTPS can claim exemption

## Quick Command Reference

```bash
# Clean project
~/flutter/bin/flutter clean

# Get dependencies
~/flutter/bin/flutter pub get

# Install pods
cd ios && pod install && cd ..

# Build for release
~/flutter/bin/flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# Run on device (for testing before archive)
~/flutter/bin/flutter run --release
```

## Timeline Expectations

- **Xcode Archive**: 5-10 minutes
- **Upload to App Store Connect**: 10-30 minutes
- **Processing**: 10-30 minutes (up to 24 hours)
- **Internal Testing**: Available immediately after processing
- **External Testing**: Requires Beta App Review (24-48 hours)

**Total Time to TestFlight (Internal)**: 1-2 hours minimum (same day is achievable!)

## Next Steps After TestFlight

1. Gather feedback from testers
2. Fix bugs and issues
3. Upload new builds as needed (increment build number each time)
4. When ready, submit for App Store Review
5. Launch on App Store!

## Important Notes

- **Build Number**: Must be unique and incremented for each upload
  - Edit in `pubspec.yaml`: `version: 1.0.0+2` (increment the number after +)
- **Version Number**: Can stay the same across TestFlight builds
- **Icons**: Ensure app icons are properly configured (1024x1024 for App Store)
- **Privacy**: Add privacy policy if your app collects user data
- **Testing**: Test thoroughly on TestFlight before submitting to App Store

## Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Flutter iOS Deployment Guide](https://docs.flutter.dev/deployment/ios)

---

## Quick Start Checklist

- [ ] Create app in App Store Connect
- [ ] Configure Xcode project (signing, bundle ID)
- [ ] Run `flutter clean && flutter pub get && cd ios && pod install`
- [ ] Build: `flutter build ios --release --no-codesign`
- [ ] Archive in Xcode: Product → Archive
- [ ] Upload to App Store Connect
- [ ] Wait for processing
- [ ] Answer export compliance questions
- [ ] Add testers
- [ ] Install TestFlight and test!

Good luck with your deployment! 🚀
