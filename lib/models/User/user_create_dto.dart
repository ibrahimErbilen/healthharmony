class UserCreateDto {
  final String username;
  final String email;
  final String passwordHash; // hash varsa, yoksa düz şifre de gönderilebilir
  final String? profileImageUrl;
  final String? registrationDate;
  final String? refreshToken;
  final String? refreshTokenExpiryTime;

  UserCreateDto({
    required this.username,
    required this.email,
    required this.passwordHash,
    this.profileImageUrl,
    this.registrationDate,
    this.refreshToken,
    this.refreshTokenExpiryTime,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'passwordHash': passwordHash,
        'profileImageUrl': profileImageUrl,
        'registrationDate': registrationDate,
        'refreshToken': refreshToken,
        'refreshTokenExpiryTime': refreshTokenExpiryTime,
      };
}
