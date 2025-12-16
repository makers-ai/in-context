import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incontext/core/providers/core_providers.dart';
import 'package:incontext/features/auth/presentation/providers/auth_providers.dart';
import 'package:incontext/features/prompts/data/repositories/firebase_prompt_repository.dart';
import 'package:incontext/features/prompts/domain/entities/prompt_entity.dart';
import 'package:incontext/features/prompts/domain/repositories/prompt_repository.dart';

// Repository provider
final promptRepositoryProvider = Provider<PromptRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebasePromptRepository(firestore, firebaseAuth);
});

// Stream provider for prompts - only active when user is authenticated
final promptsStreamProvider = StreamProvider<List<PromptEntity>>((ref) {
  // Ensure user is authenticated before accessing prompts
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  if (!isAuthenticated) {
    // Return empty stream if user is not authenticated
    return Stream.value([]);
  }

  final repository = ref.watch(promptRepositoryProvider);
  return repository.watchPrompts();
});
