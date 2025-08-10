import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  member,
  guest,
  user,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fullName;
  final String? memberCode;
  final String? createdBy;
  final DateTime? planExpiryDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.memberCode,
    this.createdBy,
    this.planExpiryDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => UserRole.guest,
      ),
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      fullName: map['fullName'],
      memberCode: map['memberCode'],
      createdBy: map['createdBy'],
      planExpiryDate: map['planExpiryDate'] != null
          ? (map['planExpiryDate'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'fullName': fullName,
      'memberCode': memberCode,
      'createdBy': createdBy,
      'planExpiryDate': planExpiryDate,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? memberCode,
    String? createdBy,
    DateTime? planExpiryDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      memberCode: memberCode ?? this.memberCode,
      createdBy: createdBy ?? this.createdBy,
      planExpiryDate: planExpiryDate ?? this.planExpiryDate,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
