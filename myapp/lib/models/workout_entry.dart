import 'package:hive/hive.dart';

part 'workout_entry.g.dart';

@HiveType(typeId: 2)
class WorkoutEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String duration;

  @HiveField(2)
  String time;

  @HiveField(3)
  DateTime date;

  WorkoutEntry({
    required this.title,
    required this.duration,
    required this.time,
    required this.date,
  });
}
