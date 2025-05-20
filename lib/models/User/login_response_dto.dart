class LoginResponseDto {
  final String userId;
  final String username;
  final String email;
  final String token;
  final String refreshToken;

  LoginResponseDto({
    required this.userId,
    required this.username,
    required this.email,
    required this.token,
    required this.refreshToken,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}
