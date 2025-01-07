import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String subtitle;

  @HiveField(2)
  bool isCompleted;

  Habit({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}
