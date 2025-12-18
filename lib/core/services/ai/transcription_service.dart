import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:incontext/core/errors/failures.dart';
import 'package:incontext/core/utils/result.dart';
import 'package:logger/logger.dart';

class TranscriptionResult {
  const TranscriptionResult({
    required this.text,
    required this.language,
  });

  final String text;
  final String language;
}

/// Service for transcribing audio using Google Cloud Speech-to-Text API
///
/// This service uses Firebase Cloud Functions to call Google Speech-to-Text,
/// keeping authentication secure on the server side.
///
/// Setup:
/// 1. Enable Speech-to-Text API in Google Cloud Console
/// 2. Deploy the transcribeAudio Cloud Function (see functions/ directory)
/// 3. The function handles authentication automatically using Firebase Admin SDK
class TranscriptionService {
  TranscriptionService({
    required FirebaseFunctions firebaseFunctions,
    Logger? logger,
  })  : _firebaseFunctions = firebaseFunctions,
        _logger = logger ?? Logger();

  final FirebaseFunctions _firebaseFunctions;
  final Logger _logger;

  /// Transcribe audio file to text using Google Cloud Speech-to-Text API
  ///
  /// This method calls a Firebase Cloud Function that handles the transcription
  /// server-side, keeping Google Cloud credentials secure.
  ///
  /// The Cloud Function should be named 'transcribeAudio' and accept:
  /// - audioUrl: The Firebase Storage URL of the audio file
  /// - languageCode: Optional language code (e.g., 'en-US')
  ///
  /// Returns a TranscriptionResult with the transcribed text and detected language.
  Future<Result<TranscriptionResult>> transcribeAudio({
    required String audioUrl,
    String? languageCode,
  }) async {
    try {
      _logger.d('Starting transcription for: $audioUrl');

      // Call Firebase Cloud Function for transcription
      final callable = _firebaseFunctions.httpsCallable('transcribeAudio');

      final result = await callable.call<Map<String, dynamic>>({
        'audioUrl': audioUrl,
        if (languageCode != null) 'languageCode': languageCode,
      });

      final data = result.data;
      if (data.containsKey('text')) {
        final transcript = data['text'] as String;
        final detectedLanguage = data['language'] as String? ?? languageCode ?? 'en-US';

        _logger.i('Transcription completed successfully');

        return Success(
          TranscriptionResult(
            text: transcript.trim(),
            language: detectedLanguage,
          ),
        );
      }

      // No text in response
      _logger.w('No transcription text in Cloud Function response');
      return Error(
        ServerFailure(
          message: 'No transcription text found in response.',
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      _logger.e('Cloud Function error during transcription', error: e);

      String errorMessage = 'Transcription failed';
      if (e.code == 'unauthenticated') {
        errorMessage = 'Authentication failed. Please sign in again.';
      } else if (e.code == 'permission-denied') {
        errorMessage = 'Permission denied. Please check your Firebase security rules.';
      } else if (e.code == 'not-found') {
        errorMessage = 'Transcription function not found. Please deploy the Cloud Function.';
      } else if (e.code == 'invalid-argument') {
        errorMessage = 'Invalid audio file. Please check the audio format.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return Error(
        ServerFailure(
          message: 'Transcription error: $errorMessage',
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Error in transcribeAudio', error: e, stackTrace: stackTrace);
      return Error(
        UnknownFailure(message: 'Transcription error: ${e.toString()}'),
      );
    }
  }
}
