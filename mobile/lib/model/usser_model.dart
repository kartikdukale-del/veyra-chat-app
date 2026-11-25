class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String about;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.about = 'Available',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      about: (json['about'] as String?)?.isNotEmpty == true
          ? json['about']
          : 'Available',
    );
  }
}
