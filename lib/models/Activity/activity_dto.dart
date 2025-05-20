class ActivityDTO {
  final int activityId;
  final String activityName;
  final String description;
  final int estimatedCaloriesBurn;
  final int difficultyLevel;
  final String? imageUrl;
  final String? videoUrl;

  ActivityDTO({
    required this.activityId,
    required this.activityName,
    required this.description,
    required this.estimatedCaloriesBurn,
    required this.difficultyLevel,
    this.imageUrl,
    this.videoUrl,
  });

  factory ActivityDTO.fromJson(Map<String, dynamic> json) {
    return ActivityDTO(
      activityId: json['activityId'],
      activityName: json['activityName'],
      description: json['description'],
      estimatedCaloriesBurn: json['estimatedCaloriesBurn'],
      difficultyLevel: json['difficultyLevel'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }
}