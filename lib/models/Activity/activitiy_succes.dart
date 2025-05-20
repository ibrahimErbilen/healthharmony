class ActivitySuccess {
  final int userActivityId;

  ActivitySuccess({
    required this.userActivityId,
  });

  Map<String, dynamic> toJson() => {
    'userActivityId': userActivityId,

 // Backend'in beklediği alan adı ile eşleşmeli
  };
}