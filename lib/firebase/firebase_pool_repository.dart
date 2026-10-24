import '../models/registration.dart';
import '../services/services.dart';

/// Cloud Firestore implementation of PoolRepository and RegistrationService.
class FirebasePoolRepository implements PoolRepository {
  @override
  Future<PoolStatus> statusOf(String studentId) async {
    // TODO: fetch waiting pool status from Firestore
    return PoolStatus(
      queueId: 'QP-$studentId',
      progress: 0.0,
      stage: 'Pending',
      expectedResult: DateTime.now().add(const Duration(days: 3)),
      preferredRoles: const ['Developer'],
      skills: const ['Flutter'],
      studentsInPool: 0,
      contactEmail: '$studentId@fpt.edu.vn',
      lastChecked: DateTime.now(),
    );
  }
}

class FirebaseRegistrationService implements RegistrationService {
  @override
  Future<RegistrationWindow> currentWindow() async {
    // TODO: fetch current registration deadline from Firestore / RemoteConfig
    final now = DateTime.now();
    return RegistrationWindow(
      semester: 'Spring 2026',
      opensAt: now.subtract(const Duration(days: 7)),
      closesAt: now.add(const Duration(days: 7)),
    );
  }
}
