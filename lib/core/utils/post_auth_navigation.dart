import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:apartmate/data/models/society_model.dart';
import 'package:apartmate/domain/repositories/i_auth_repository.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/routes/app_routes.dart';

/// Same routing rules as AuthController._navigateAfterAuth
/// (used from splash / app resume).
Future<void> navigateAfterAuth() async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) {
    Get.offAllNamed(AppRoutes.login);
    return;
  }

  try {
    // Prefer profile from repository when available
    final profile = Get.isRegistered<IAuthRepository>()
        ? Get.find<IAuthRepository>().currentUser
        : null;

    final fullName = (profile?.fullName ?? firebaseUser.displayName ?? '').trim();
    final phone = (profile?.phone ?? '').trim();

    // Incomplete signup → Signup
    if (fullName.isEmpty || phone.isEmpty) {
      Get.offAllNamed(AppRoutes.signup);
      return;
    }

    final society = await Get.find<ISocietyRepository>().getCurrentSociety();

    // No society → Society Register
    if (society == null) {
      Get.offAllNamed(AppRoutes.societyRegister);
      return;
    }

    // Not approved → Registration Status
    if (society.registrationStatus != SocietyRegistrationStatus.approved) {
      Get.offAllNamed(AppRoutes.registrationStatus);
      return;
    }

    // Approved, no buildings → Society Buildings
    final buildings = await Get.find<ISocietyRepository>().getBuildings();
    if (buildings.isEmpty) {
      Get.offAllNamed(AppRoutes.societyBuildings);
      return;
    }

    // Fully set up → Dashboard
    Get.offAllNamed(AppRoutes.dashboard);
  } catch (_) {
    Get.offAllNamed(AppRoutes.login);
  }
}