class UserDto {
  final String userId;
  final String username;
  final String email;
  final String? profileImageUrl;
  final DateTime registrationDate;

  UserDto({
    required this.userId,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.registrationDate,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      registrationDate: DateTime.parse(json['registrationDate']),
    );
  }
}