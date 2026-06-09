class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        role: json['role'],
        isVerified: json['isVerified'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
        'isVerified': isVerified,
      };

  bool get isAdmin => role == 'ADMIN';
}
