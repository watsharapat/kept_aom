import 'package:kept_aom/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kept_aom/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<void> build() {
    // Initial state is empty
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
