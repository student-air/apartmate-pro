import 'package:get/get.dart';
import 'package:apartmate/data/repositories/firebase_auth_repository.dart';
import 'package:apartmate/data/repositories/firebase_society_repository.dart';
import 'package:apartmate/domain/repositories/i_auth_repository.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/data/repositories/firebase_staff_repository.dart';
import 'package:apartmate/domain/repositories/i_staff_repository.dart';
import 'package:apartmate/domain/repositories/i_dashboard_repository.dart';
import 'package:apartmate/data/repositories/firebase_dashboard_repository.dart';
import 'package:apartmate/data/repositories/firebase_update_repository.dart';
import 'package:apartmate/domain/repositories/i_update_repository.dart';
import 'package:apartmate/presentation/updates/controllers/updates_badge_controller.dart';
import 'package:apartmate/data/repositories/firebase_request_repository.dart';
import 'package:apartmate/domain/repositories/i_request_repository.dart';
import 'package:apartmate/data/repositories/firebase_resident_repository.dart';
import 'package:apartmate/domain/repositories/i_resident_repository.dart';
import 'package:apartmate/data/repositories/firebase_complaint_repository.dart';
import 'package:apartmate/domain/repositories/i_complaint_repository.dart';
import 'package:apartmate/data/repositories/firebase_owner_repository.dart';
import 'package:apartmate/domain/repositories/i_owner_repository.dart';
import 'package:apartmate/data/repositories/firebase_committee_repository.dart';
import 'package:apartmate/domain/repositories/i_committee_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IAuthRepository>(FirebaseAuthRepository(), permanent: true);
    Get.put<ISocietyRepository>(FirebaseSocietyRepository(), permanent: true);
    Get.put<IStaffRepository>(FirebaseStaffRepository(), permanent: true);
    Get.put<IDashboardRepository>(
      FirebaseDashboardRepository(
        Get.find<ISocietyRepository>(),
        Get.find<IStaffRepository>(),
      ),
      permanent: true,
    );
    Get.put<IUpdateRepository>(FirebaseUpdateRepository(), permanent: true);
    Get.put<UpdatesBadgeController>(UpdatesBadgeController(), permanent: true);
    Get.put<IRequestRepository>(FirebaseRequestRepository(), permanent: true);
    Get.put<IResidentRepository>(FirebaseResidentRepository(), permanent: true);
    Get.put<IComplaintRepository>(FirebaseComplaintRepository(), permanent: true);
    Get.put<IOwnerRepository>(FirebaseOwnerRepository(), permanent: true);
    Get.put<ICommitteeRepository>(FirebaseCommitteeRepository(), permanent: true);
  }
}