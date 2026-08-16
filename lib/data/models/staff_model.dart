enum StaffRole { admin, reception, electrician, plumber, securityGuard, other }

extension StaffRoleX on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.admin:
        return 'Admin';
      case StaffRole.reception:
        return 'Reception';
      case StaffRole.electrician:
        return 'Electrician';
      case StaffRole.plumber:
        return 'Plumber';
      case StaffRole.securityGuard:
        return 'Security Guard';
      case StaffRole.other:
        return 'Other';
    }
  }
}

enum StaffStatus { pending, active }

class StaffModel {
  final String id;
  final String name;
  final String phone;
  final String cnic;
  final StaffRole role;
  final String? customRoleLabel;
  final String? photoPath;
  final StaffStatus status;

  const StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.cnic,
    required this.role,
    this.customRoleLabel,
    this.photoPath,
    this.status = StaffStatus.pending,
  });

  /// Display label — falls back to the entered custom text when role is
  /// StaffRole.other, otherwise the fixed enum label.
  String get roleDisplayLabel {
    if (role == StaffRole.other &&
        (customRoleLabel?.trim().isNotEmpty ?? false)) {
      return customRoleLabel!.trim();
    }
    return role.label;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters =
        parts.take(2).map((e) => e.isNotEmpty ? e[0] : '').join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  StaffModel copyWith({
    String? name,
    String? phone,
    String? cnic,
    StaffRole? role,
    String? customRoleLabel,
    String? photoPath,
    StaffStatus? status,
  }) {
    return StaffModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      role: role ?? this.role,
      customRoleLabel: customRoleLabel ?? this.customRoleLabel,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
    );
  }
}