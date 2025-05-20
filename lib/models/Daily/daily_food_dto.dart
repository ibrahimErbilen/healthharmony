class DailyFoodDto {
  final int dailyFoodEatID;
  final String userId;
  final String foodName;
  final int calories;
  final DateTime eatTime;

  DailyFoodDto({
    required this.dailyFoodEatID,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.eatTime,
  });

  factory DailyFoodDto.fromJson(Map<String, dynamic> json) {
  return DailyFoodDto(
    dailyFoodEatID: json['dailyFoodEatID'] is int ? json['dailyFoodEatID'] : int.tryParse(json['dailyFoodEatID']?.toString() ?? '0') ?? 0,
    userId: json['userId'] ?? '',
    foodName: json['foodName'] ?? '',
    calories: json['calories'] is int ? json['calories'] : int.tryParse(json['calories']?.toString() ?? '0') ?? 0,
    eatTime: json['eatTime'] != null ? DateTime.parse(json['eatTime']) : DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'dailyFoodEatID': dailyFoodEatID,
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'eatTime': eatTime.toIso8601String(),
    };
  }
}
