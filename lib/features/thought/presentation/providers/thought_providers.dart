import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/providers/core_providers.dart';
import 'package:incontext/features/thought/data/repositories/firebase_thought_repository.dart';
import 'package:incontext/features/thought/domain/entities/thought_entity.dart';
import 'package:incontext/features/thought/domain/repositories/thought_repository.dart';

/// *** REPOSITORIES *** ///
/// Thought repository provider
final thoughtRepositoryProvider = Provider<ThoughtRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseThoughtRepository(firestore, firebaseAuth);
});

/// *** STREAM PROVIDERS *** ///
/// Stream provider family for thoughts in a project
final thoughtsStreamProvider = StreamProvider.family<List<ThoughtEntity>, String>((ref, projectId) {
  final repository = ref.watch(thoughtRepositoryProvider);
  return repository.watchThoughts(projectId);
});
