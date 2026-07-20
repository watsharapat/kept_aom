class SavingGoalEntity {
  final String userId;
  final String name;
  final int statusId;
  final int stored;
  final int target;

  SavingGoalEntity({
    required this.userId,
    required this.name,
    required this.statusId,
    required this.stored,
    required this.target,
  });
}
