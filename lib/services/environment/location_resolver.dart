import '../../models/environmental_snapshot.dart';
import '../auth/auth_repository.dart';

abstract class LocationResolver {
  Future<ResolvedLocation> resolve(AuthRepository auth);
}
