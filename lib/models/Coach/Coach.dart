class Coach {
  final String coachId;
  final String coachName;
  final String email;
  final String passwordHash;
  final String invitationCode;
  final String profileImageUrl;
  final int coachType;
  final String specialization;
  final String experience;

  Coach({
    required this.coachId,
    required this.coachName,
    required this.email,
    required this.passwordHash,
    required this.invitationCode,
    required this.profileImageUrl,
    required this.coachType,
    required this.specialization,
    required this.experience,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      coachId: json['coachId'],
      coachName: json['coachName'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      invitationCode: json['invitationCode'],
      profileImageUrl: json['profileImageUrl'],
      coachType: json['coachType'],
      specialization: json['specialization'],
      experience: json['experience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coachId': coachId,
      'coachName': coachName,
      'email': email,
      'passwordHash': passwordHash,
      'invitationCode': invitationCode,
      'profileImageUrl': profileImageUrl,
      'coachType': coachType,
      'specialization': specialization,
      'experience': experience,
    };
  }
}
