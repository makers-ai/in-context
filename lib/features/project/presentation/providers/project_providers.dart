import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/providers/core_providers.dart';
import 'package:incontext/core/utils/result.dart';
import 'package:incontext/features/project/data/repositories/firebase_project_repository.dart';
import 'package:incontext/features/project/domain/entities/project_entity.dart';
import 'package:incontext/features/project/domain/repositories/project_repository.dart';

/// *** REPOSITORIES *** ///
/// Project repository provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseProjectRepository(firestore, firebaseAuth);
});

/// *** STREAM PROVIDERS *** ///
/// Stream provider for all projects
final projectsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects();
});

/// Provider family for a specific project
final projectProvider =
    FutureProvider.family<ProjectEntity, String>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  final result = await repository.getProject(projectId);
  return result.when(
    success: (project) => project,
    error: (failure) => throw failure,
  );
});
