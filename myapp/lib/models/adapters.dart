import 'package:hive/hive.dart';
import 'habit.dart';
import 'meal_entry.dart';
import 'workout_entry.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    return Habit(
      title: reader.read(),
      subtitle: reader.read(),
      isCompleted: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.write(obj.title);
    writer.write(obj.subtitle);
    writer.write(obj.isCompleted);
  }
}

class MealEntryAdapter extends TypeAdapter<MealEntry> {
  @override
  final int typeId = 1;

  @override
  MealEntry read(BinaryReader reader) {
    return MealEntry(
      mealType: reader.read(),
      calories: reader.read(),
      items: List<String>.from(reader.read()),
      dateTime: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MealEntry obj) {
    writer.write(obj.mealType);
    writer.write(obj.calories);
    writer.write(obj.items);
    writer.write(obj.dateTime);
  }
}

class WorkoutEntryAdapter extends TypeAdapter<WorkoutEntry> {
  @override
  final int typeId = 2;

  @override
  WorkoutEntry read(BinaryReader reader) {
    return WorkoutEntry(
      title: reader.read(),
      duration: reader.read(),
      time: reader.read(),
      date: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutEntry obj) {
    writer.write(obj.title);
    writer.write(obj.duration);
    writer.write(obj.time);
    writer.write(obj.date);
  }
}
