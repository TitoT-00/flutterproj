import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal_entry.dart';

class CalorieTrackerPage extends StatefulWidget {
  const CalorieTrackerPage({super.key});

  @override
  State<CalorieTrackerPage> createState() => _CalorieTrackerPageState();
}

class _CalorieTrackerPageState extends State<CalorieTrackerPage> {
  List<MealEntry> meals = [];
  late int dailyGoal;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final box = Hive.box('mybox');
    final storedMeals = box.get('meals');
    final storedGoal = box.get('dailyCalorieGoal');
    
    if (storedMeals != null) {
      meals = List<MealEntry>.from(storedMeals);
    }
    dailyGoal = storedGoal ?? 2000;
    setState(() {});
  }

  void _changeDailyGoal() {
    showDialog(
      context: context,
      builder: (context) {
        String newGoal = dailyGoal.toString();
        return AlertDialog(
          title: const Text('Change Daily Goal'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Daily Calorie Goal',
              suffix: Text('calories'),
            ),
            controller: TextEditingController(text: dailyGoal.toString()),
            onChanged: (value) => newGoal = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newGoal.isNotEmpty) {
                  setState(() {
                    dailyGoal = int.parse(newGoal);
                    Hive.box('mybox').put('dailyCalorieGoal', dailyGoal);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<MealEntry> _getTodaysMeals() {
    return meals.where((meal) =>
      meal.dateTime.year == selectedDate.year &&
      meal.dateTime.month == selectedDate.month &&
      meal.dateTime.day == selectedDate.day
    ).toList();
  }

  int _calculateTotalCalories() {
    return _getTodaysMeals().fold(0, (sum, meal) => sum + meal.calories);
  }

  void _addMeal() {
    showDialog(
      context: context,
      builder: (context) {
        String mealType = 'Breakfast';
        final caloriesController = TextEditingController();
        final itemsController = TextEditingController();
        List<String> items = [];
        String? caloriesError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isValidCalories(String value) {
              if (value.isEmpty) return false;
              try {
                final calories = int.parse(value);
                return calories > 0;
              } catch (e) {
                return false;
              }
            }

            void validateCalories(String value) {
              if (value.isEmpty) {
                setDialogState(() => caloriesError = 'Please enter calories');
              } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                setDialogState(() => caloriesError = 'Please enter a valid number');
              } else if (int.parse(value) <= 0) {
                setDialogState(() => caloriesError = 'Calories must be greater than 0');
              } else {
                setDialogState(() => caloriesError = null);
              }
            }

            return AlertDialog(
              title: const Text('Add Meal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: mealType,
                      decoration: const InputDecoration(
                        labelText: 'Meal Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => mealType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: caloriesController,
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        errorText: caloriesError,
                        border: const OutlineInputBorder(),
                        suffix: const Text('cal'),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: validateCalories,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: itemsController,
                            decoration: const InputDecoration(
                              labelText: 'Food Item',
                              helperText: 'Press Enter or Add to add item',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                setDialogState(() {
                                  items.add(value);
                                  itemsController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: Colors.blue,
                          onPressed: () {
                            if (itemsController.text.isNotEmpty) {
                              setDialogState(() {
                                items.add(itemsController.text);
                                itemsController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (items.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Added Items:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: items
                              .map((item) => Chip(
                                    label: Text(item),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setDialogState(() {
                                        items.remove(item);
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add at least one food item'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (!isValidCalories(caloriesController.text)) {
                      validateCalories(caloriesController.text);
                      return;
                    }

                    final newMeal = MealEntry(
                      mealType: mealType,
                      calories: int.parse(caloriesController.text),
                      items: items,
                      dateTime: DateTime.now(),
                    );
                    
                    setState(() {
                      meals.add(newMeal);
                      Hive.box('mybox').put('meals', meals);
                    });
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Add Meal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteMeal(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                meals.removeAt(index);
                Hive.box('mybox').put('meals', meals);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal deleted'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todaysMeals = _getTodaysMeals();
    final totalCalories = _calculateTotalCalories();
    final remainingCalories = dailyGoal - totalCalories;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calorie Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _changeDailyGoal,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daily Goal:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Row(
                            children: [
                              Text(
                                '$dailyGoal cal',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 16),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: totalCalories / dailyGoal,
                        backgroundColor: Colors.grey[300],
                        color: remainingCalories >= 0 ? Colors.blue : Colors.red,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Consumed: $totalCalories cal'),
                          Text(
                            'Remaining: $remainingCalories cal',
                            style: TextStyle(
                              color: remainingCalories >= 0
                                  ? Colors.black
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Today\'s Meals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: todaysMeals.length,
                  itemBuilder: (context, index) {
                    final meal = todaysMeals[index];
                    return Dismissible(
                      key: Key(meal.dateTime.toString() + meal.mealType),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (direction) async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Meal'),
                            content: const Text('Are you sure you want to delete this meal?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        return result ?? false;
                      },
                      onDismissed: (_) {
                        _deleteMeal(meals.indexOf(meal));
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.restaurant_menu,
                            color: Colors.blue[300],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${meal.calories} cal',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteMeal(meals.indexOf(meal)),
                              ),
                            ],
                          ),
                          title: Text(meal.mealType),
                          subtitle: Text(
                            '${meal.items.length} items',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Items:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: meal.items
                                        .map((item) => Chip(
                                              label: Text(item),
                                              backgroundColor: Colors.blue[50],
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
