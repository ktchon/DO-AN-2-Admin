class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
  });

  String get fullName => "$firstName $lastName".trim();

  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return ProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}