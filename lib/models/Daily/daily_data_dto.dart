class DailyDataDTO {
  final int? dailyDataId;
  final String? userId;
  final DateTime date;
  final int stepCount;
  final int caloriesBurned;
  final int caloriesConsumed;

  DailyDataDTO({
    this.dailyDataId,
    required this.userId,
    required this.date,
    required this.stepCount,
    required this.caloriesBurned,
    required this.caloriesConsumed,
  });

  factory DailyDataDTO.fromJson(Map<String, dynamic> json) {
    return DailyDataDTO(
      dailyDataId: json['dailyDataId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      stepCount: json['stepCount'],
      caloriesBurned: json['caloriesBurned'],
      caloriesConsumed: json['caloriesConsumed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyDataId': dailyDataId,
        'userId': userId,
        'date': date.toIso8601String(),
        'stepCount': stepCount,
        'caloriesBurned': caloriesBurned,
        'caloriesConsumed': caloriesConsumed,
      };
}
