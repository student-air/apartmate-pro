enum RequestStatus { pending, accepted, rejected }

enum RequestApplicantType { owner, tenant, staff }

class RequestModel {
  final String id;
  final String buildingId;
  final String buildingName;
  final int floor;
  final String flatNumber;
  final String flatType;
  final String tenantName;
  final String cnic;
  final String phone;
  final String email;
  final int residentsCount;
  final DateTime allotmentDate;
  final int leaseDurationMonths;
  final double rent;
  final String profession;
  final String employerCompany;
  final String previousAddress;
  final String emergencyContact;
  final RequestStatus status;
  final DateTime submittedAt;
  final RequestApplicantType applicantType; // NEW

  RequestModel({
    required this.id,
    required this.buildingId,
    required this.buildingName,
    required this.floor,
    required this.flatNumber,
    required this.flatType,
    required this.tenantName,
    required this.cnic,
    required this.phone,
    required this.email,
    required this.residentsCount,
    required this.allotmentDate,
    required this.leaseDurationMonths,
    required this.rent,
    required this.profession,
    required this.employerCompany,
    required this.previousAddress,
    required this.emergencyContact,
    required this.status,
    required this.submittedAt,
    this.applicantType = RequestApplicantType.tenant, // default tenant
  });

  String get initials {
    final parts = tenantName.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((e) => e.isNotEmpty ? e[0] : '').join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  RequestModel copyWith({
    RequestStatus? status,
    RequestApplicantType? applicantType,
  }) {
    return RequestModel(
      id: id,
      buildingId: buildingId,
      buildingName: buildingName,
      floor: floor,
      flatNumber: flatNumber,
      flatType: flatType,
      tenantName: tenantName,
      cnic: cnic,
      phone: phone,
      email: email,
      residentsCount: residentsCount,
      allotmentDate: allotmentDate,
      leaseDurationMonths: leaseDurationMonths,
      rent: rent,
      profession: profession,
      employerCompany: employerCompany,
      previousAddress: previousAddress,
      emergencyContact: emergencyContact,
      status: status ?? this.status,
      submittedAt: submittedAt,
      applicantType: applicantType ?? this.applicantType,
    );
  }
}