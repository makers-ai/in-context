# incontext

A Flutter application for context-first thinking and thought management.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Variables

This project requires the following environment variables in a `.env` file at the root:

- `GOOGLE_AI_API_KEY` - Your Google AI (Gemini) API key for AI features

See `FIREBASE_SETUP.md` for Firebase configuration details.

## Speech-to-Text Transcription

This app uses **Google Cloud Speech-to-Text** via Firebase Cloud Functions for transcribing audio recordings.

### Setup Instructions

1. **Enable Speech-to-Text API**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Select your Firebase project
   - Navigate to "APIs & Services" > "Library"
   - Search for "Cloud Speech-to-Text API"
   - Click "Enable"

2. **Grant IAM Permissions to Cloud Function** (IMPORTANT):
   
   The Cloud Function's service account needs permission to use the Speech-to-Text API.
   
   **Option A: Using Google Cloud Console (Recommended)**
   - Go to [Google Cloud Console IAM](https://console.cloud.google.com/iam-admin/iam)
   - Select your Firebase project
   - Find the service account: `PROJECT_ID@appspot.gserviceaccount.com` (replace PROJECT_ID with your project ID)
   - Click the edit icon (pencil) next to the service account
   - Click "ADD ANOTHER ROLE"
   - Select "Cloud Speech Client" role
   - Click "SAVE"
   
   **Option B: Using gcloud CLI**
   ```bash
   # Get your project ID
   PROJECT_ID=$(firebase projects:list | grep -oP '(?<=\[).*?(?=\])' | head -1)
   
   # Grant the Cloud Speech Client role
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:${PROJECT_ID}@appspot.gserviceaccount.com" \
     --role="roles/speech.client"
   ```

3. **Deploy Cloud Functions**:
   ```bash
   cd functions
   npm install
   cd ..
   firebase deploy --only functions
   ```

4. **Verify Setup**:
   - The Cloud Function `transcribeAudio` will be automatically deployed
   - Authentication is handled server-side using Firebase Admin SDK
   - No API keys needed in your Flutter app!

### Troubleshooting

**"Permission denied" Error:**
- Make sure you've granted the "Cloud Speech Client" role to the Cloud Function service account (step 2 above)
- Verify the Speech-to-Text API is enabled (step 1 above)
- Wait a few minutes after granting permissions for them to propagate

**To find your project ID:**
```bash
firebase projects:list
```
Or check your `firebase.json` or Firebase Console.

### How It Works

- Audio files are uploaded to Firebase Storage
- The Flutter app calls the `transcribeAudio` Cloud Function
- The Cloud Function downloads the audio and calls Google Speech-to-Text API
- Transcription results are returned to the app
- All credentials stay secure on the server side
