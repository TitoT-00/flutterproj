import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/workout_entry.dart';

class FitnessCalendarPage extends StatefulWidget {
  const FitnessCalendarPage({super.key});

  @override
  State<FitnessCalendarPage> createState() => _FitnessCalendarPageState();
}

class _FitnessCalendarPageState extends State<FitnessCalendarPage> {
  late List<WorkoutEntry> workouts;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    final box = Hive.box('mybox');
    final storedWorkouts = box.get('workouts');
    if (storedWorkouts == null) {
      workouts = [];
    } else {
      workouts = List<WorkoutEntry>.from(storedWorkouts);
    }
    setState(() {});
  }

  void _addWorkout() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String duration = '';
        String time = '';
        return AlertDialog(
          title: const Text('Add Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Workout Name'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Duration (e.g., 30 mins)'),
                onChanged: (value) => duration = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Time (e.g., 6:00 AM)'),
                onChanged: (value) => time = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && duration.isNotEmpty && time.isNotEmpty) {
                  setState(() {
                    workouts.add(WorkoutEntry(
                      title: title,
                      duration: duration,
                      time: time,
                      date: _selectedDay,
                    ));
                    Hive.box('mybox').put('workouts', workouts);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
      Hive.box('mybox').put('workouts', workouts);
    });
  }

  List<WorkoutEntry> _getWorkoutsForSelectedDay() {
    return workouts.where((workout) =>
      workout.date.year == _selectedDay.year &&
      workout.date.month == _selectedDay.month &&
      workout.date.day == _selectedDay.day
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayWorkouts = _getWorkoutsForSelectedDay();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) {
                return workouts.where((workout) =>
                  workout.date.year == day.year &&
                  workout.date.month == day.month &&
                  workout.date.day == day.day
                ).toList();
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Workouts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: selectedDayWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = selectedDayWorkouts[index];
                  return Dismissible(
                    key: Key(workout.title + workout.time),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) {
                      _deleteWorkout(workouts.indexOf(workout));
                    },
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(workout.title),
                        subtitle: Text('${workout.duration} • ${workout.time}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }
}
