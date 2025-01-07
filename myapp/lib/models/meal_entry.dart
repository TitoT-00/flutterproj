import 'dart:core';
import 'package:hive/hive.dart';

part 'meal_entry.g.dart';

@HiveType(typeId: 1)
class MealEntry extends HiveObject {
  @HiveField(0)
  String mealType;

  @HiveField(1)
  int calories;

  @HiveField(2)
  List<String> items;

  @HiveField(3)
  DateTime dateTime;

  MealEntry({
    required this.mealType,
    required this.calories,
    required this.items,
    required this.dateTime,
  });
}
