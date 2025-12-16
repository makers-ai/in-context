const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { SpeechClient } = require('@google-cloud/speech');
const axios = require('axios');

admin.initializeApp();

const speechClient = new SpeechClient();

/**
 * Cloud Function to transcribe audio using Google Cloud Speech-to-Text API
 * 
 * This function:
 * 1. Downloads the audio file from Firebase Storage URL
 * 2. Sends it to Google Cloud Speech-to-Text API
 * 3. Returns the transcribed text and detected language
 * 
 * @param {Object} data - Request data containing audioUrl and optional languageCode
 * @param {Object} context - Firebase Functions context
 * @returns {Promise<Object>} Object with text and language fields
 */
exports.transcribeAudio = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to transcribe audio'
    );
  }

  const { audioUrl, languageCode } = data;

  if (!audioUrl) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'audioUrl is required'
    );
  }

  try {
    // Download audio file from Firebase Storage URL
    const audioResponse = await axios.get(audioUrl, {
      responseType: 'arraybuffer',
      timeout: 30000, // 30 second timeout
    });

    const audioBytes = Buffer.from(audioResponse.data);

    // Prepare request for Google Cloud Speech-to-Text
    const request = {
      audio: {
        content: audioBytes.toString('base64'),
      },
      config: {
        encoding: 'MP3', // M4A files are typically AAC, but we'll try MP3 first
        sampleRateHertz: 44100,
        languageCode: languageCode || 'en-US',
        enableAutomaticPunctuation: true,
        model: 'latest_long', // Best for longer audio recordings
        alternativeLanguageCodes: ['en-US', 'es-US'], // Support multiple languages
      },
    };

    // Call Google Cloud Speech-to-Text API
    const [response] = await speechClient.recognize(request);

    if (!response.results || response.results.length === 0) {
      // Try with different encoding if MP3 fails
      request.config.encoding = 'LINEAR16';
      const [retryResponse] = await speechClient.recognize(request);
      
      if (!retryResponse.results || retryResponse.results.length === 0) {
        throw new functions.https.HttpsError(
          'not-found',
          'No transcription results found. The audio might be too short or unclear.'
        );
      }

      const result = retryResponse.results[0];
      const alternative = result.alternatives[0];
      
      return {
        text: alternative.transcript,
        language: response.languageCode || languageCode || 'en-US',
      };
    }

    const result = response.results[0];
    const alternative = result.alternatives[0];

    return {
      text: alternative.transcript,
      language: response.languageCode || languageCode || 'en-US',
    };
  } catch (error) {
    console.error('Error transcribing audio:', error);
    console.error('Error details:', {
      code: error.code,
      message: error.message,
      details: error.details,
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Handle specific Google Cloud errors
    if (error.code === 3) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid audio format or encoding'
      );
    }

    // Error code 7 = PERMISSION_DENIED
    if (error.code === 7 || error.message?.includes('PERMISSION_DENIED')) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Permission denied. The Cloud Function service account needs the "Cloud Speech Client" role. ' +
        'See README.md for setup instructions.'
      );
    }

    // Error code 5 = NOT_FOUND (API not enabled)
    if (error.code === 5 || error.message?.includes('API not enabled')) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Speech-to-Text API is not enabled. Please enable it in Google Cloud Console.'
      );
    }

    throw new functions.https.HttpsError(
      'internal',
      `Transcription failed: ${error.message || 'Unknown error'}`
    );
  }
});

