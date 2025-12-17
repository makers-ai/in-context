import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/providers/core_providers.dart';
import 'package:incontext/features/context/data/repositories/firebase_context_repository.dart';
import 'package:incontext/features/context/domain/entities/context_entity.dart';
import 'package:incontext/features/context/domain/repositories/context_repository.dart';
import 'package:incontext/features/output/data/repositories/firebase_output_repository.dart';
import 'package:incontext/features/output/domain/entities/output_entity.dart';
import 'package:incontext/features/output/domain/repositories/output_repository.dart';

/// *** REPOSITORIES *** ///
/// Context repository provider
final contextRepositoryProvider = Provider<ContextRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseContextRepository(firestore, firebaseAuth);
});

/// Output repository provider
final outputRepositoryProvider = Provider<OutputRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseOutputRepository(firestore, firebaseAuth);
});

/// *** STREAM PROVIDERS *** ///
/// Stream provider family for context in a project
final contextStreamProvider =
    StreamProvider.family<ContextEntity?, String>((ref, projectId) {
  final repository = ref.watch(contextRepositoryProvider);
  return repository.watchContextForProject(projectId);
});

/// Stream provider family for outputs for a context
final outputsStreamProvider =
    StreamProvider.family<List<OutputEntity>, ({String projectId, String contextId})>((ref, params) {
  final repository = ref.watch(outputRepositoryProvider);
  return repository.watchOutputs(params.projectId, params.contextId);
});
