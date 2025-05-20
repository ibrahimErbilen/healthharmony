// lib/models/Activity/user_activity_dto.dart (veya modelinizin bulunduğu dosya)

class UserActivityDTO {
  final int userActivityId;
  final String userId;
  final int activityId;
  final String activityName;
  final String description;
  final DateTime addedDate;
  final DateTime? completionDate; // Bu nullable kalacak
  final bool isCompleted;

  UserActivityDTO({
    required this.userActivityId,
    required this.userId,
    required this.activityId,
    required this.activityName,
    required this.description,
    required this.addedDate,
    this.completionDate, // Nullable
    required this.isCompleted,
  });

  factory UserActivityDTO.fromJson(Map<String, dynamic> json) {
    return UserActivityDTO(
      userActivityId: json['userActivityId'] as int,
      userId: json['userId'] as String,
      activityId: json['activityId'] as int,
      activityName: json['activityName'] as String,
      description: json['description'] as String? ?? 'Açıklama yok', // Gelen null ise varsayılan
      addedDate: DateTime.parse(json['addedDate'] as String),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userActivityId': userActivityId,
      'userId': userId,
      'activityId': activityId,
      'activityName': activityName,
      'description': description,
      'addedDate': addedDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(), // Null ise JSON'a null olarak gider
      'isCompleted': isCompleted,
    };
  }

  UserActivityDTO copyWith({
    int? userActivityId,
    String? userId,
    int? activityId,
    String? activityName,
    String? description,
    DateTime? addedDate,
    DateTime? completionDate, // Bu null olabilir
    bool? clearCompletionDate, // completionDate'i özellikle null yapmak için flag
    bool? isCompleted,
  }) {
    return UserActivityDTO(
      userActivityId: userActivityId ?? this.userActivityId,
      userId: userId ?? this.userId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      description: description ?? this.description,
      addedDate: addedDate ?? this.addedDate,
      completionDate: clearCompletionDate == true ? null : (completionDate ?? this.completionDate),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}