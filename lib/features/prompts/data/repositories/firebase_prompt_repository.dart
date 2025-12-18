import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:incontext/core/errors/failures.dart';
import 'package:incontext/core/utils/result.dart';
import 'package:incontext/features/prompts/data/models/prompt_model.dart';
import 'package:incontext/features/prompts/data/services/default_prompts_service.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';
import 'package:incontext/features/prompts/domain/repositories/prompt_repository.dart';

class FirebasePromptRepository implements PromptRepository {
  FirebasePromptRepository(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  String? get _userId {
    final user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  CollectionReference<Map<String, dynamic>> get _promptsCollection =>
      _firestore.collection('users').doc(_userId).collection('prompts');

  @override
  Future<Result<List<PromptEntity>>> getPrompts() async {
    if (_userId == null) {
      return Error(ServerFailure(message: 'User not authenticated'));
    }

    try {
      final snapshot = await _promptsCollection.orderBy('updatedAt', descending: true).get();

      // If no prompts exist, create default ones
      if (snapshot.docs.isEmpty) {
        await _createDefaultPrompts();
        // Re-fetch after creating defaults
        final newSnapshot = await _promptsCollection.orderBy('updatedAt', descending: true).get();
        final prompts =
            newSnapshot.docs.map((doc) => PromptModel.fromFirestore(doc).toEntity()).toList();
        return Success(prompts);
      }

      final prompts =
          snapshot.docs.map((doc) => PromptModel.fromFirestore(doc).toEntity()).toList();

      return Success(prompts);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to load prompts: $e'));
    }
  }

  Future<void> _createDefaultPrompts() async {
    final defaultPrompts = DefaultPromptsService.getDefaultPrompts();
    final batch = _firestore.batch();

    for (final prompt in defaultPrompts) {
      final docRef = _promptsCollection.doc();
      batch.set(docRef, {
        'name': prompt.name,
        'description': prompt.description,
        'promptTemplate': prompt.promptTemplate,
        'createdAt': prompt.createdAt,
        'updatedAt': prompt.updatedAt,
      });
    }

    await batch.commit();
  }

  @override
  Future<Result<PromptEntity>> createPrompt({
    required String name,
    required String description,
    required String promptTemplate,
  }) async {
    if (_userId == null) {
      return Error(ServerFailure(message: 'User not authenticated'));
    }

    try {
      final now = DateTime.now();
      final promptData = {
        'name': name,
        'description': description,
        'version': '1.0.0',
        'promptTemplate': promptTemplate,
        'createdAt': now,
        'updatedAt': now,
      };

      final docRef = await _promptsCollection.add(promptData);
      final doc = await docRef.get();

      final prompt = PromptModel.fromFirestore(doc).toEntity();
      return Success(prompt);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to create prompt: $e'));
    }
  }

  @override
  Future<Result<PromptEntity>> updatePrompt({
    required String id,
    required String name,
    required String description,
    required String promptTemplate,
  }) async {
    if (_userId == null) {
      return Error(ServerFailure(message: 'User not authenticated'));
    }

    try {
      // Get current version and increment it
      final currentDoc = await _promptsCollection.doc(id).get();
      final currentData = currentDoc.data() as Map<String, dynamic>;
      final currentVersion = currentData['version'] as String? ?? '1.0.0';
      final versionParts = currentVersion.split('.');
      final newVersion = '${versionParts[0]}.${versionParts[1]}.${int.parse(versionParts[2]) + 1}';

      final updateData = {
        'name': name,
        'description': description,
        'version': newVersion,
        'promptTemplate': promptTemplate,
        'updatedAt': DateTime.now(),
      };

      await _promptsCollection.doc(id).update(updateData);
      final doc = await _promptsCollection.doc(id).get();

      final prompt = PromptModel.fromFirestore(doc).toEntity();
      return Success(prompt);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to update prompt: $e'));
    }
  }

  @override
  Future<Result<void>> deletePrompt(String id) async {
    if (_userId == null) {
      return Error(ServerFailure(message: 'User not authenticated'));
    }

    try {
      await _promptsCollection.doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to delete prompt: $e'));
    }
  }

  @override
  Stream<List<PromptEntity>> watchPrompts() {
    if (_userId == null) {
      // Return empty stream if user is not authenticated
      return Stream.value([]);
    }

    return _promptsCollection.orderBy('updatedAt', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PromptModel.fromFirestore(doc).toEntity()).toList());
  }
}
