class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiration;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.expiration,
  });

 factory TokenResponse.fromJson(Map<String, dynamic> json) {
  if (json['token'] == null || json['refreshToken'] == null) {
    throw Exception('Token veya Refresh Token bulunamadi.');
  }
  
  return TokenResponse(
    accessToken: json['token'],
    refreshToken: json['refreshToken'],
    expiration: json['expiration'] != null ? DateTime.parse(json['expiration']) : null,
  );
}}