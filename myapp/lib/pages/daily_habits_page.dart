import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class DailyHabitsPage extends StatefulWidget {
  const DailyHabitsPage({super.key});

  @override
  State<DailyHabitsPage> createState() => _DailyHabitsPageState();
}

class _DailyHabitsPageState extends State<DailyHabitsPage> with SingleTickerProviderStateMixin {
  List<Habit> habits = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHabits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadHabits() {
    final habitsBox = Hive.box('mybox');
    final storedHabits = habitsBox.get('habits');
    if (storedHabits == null) {
      habits = [
        Habit(
          title: 'Morning Exercise',
          subtitle: 'Complete 30 minutes workout',
        ),
        Habit(
          title: 'Drink Water',
          subtitle: '8 glasses per day',
        ),
        Habit(
          title: 'Meditation',
          subtitle: '15 minutes mindfulness',
        ),
      ];
      habitsBox.put('habits', habits);
    } else {
      habits = List<Habit>.from(storedHabits);
    }
    setState(() {});
  }

  void _toggleHabit(int index) {
    setState(() {
      habits[index].isCompleted = !habits[index].isCompleted;
      Hive.box('mybox').put('habits', habits);
    });
  }

  void _deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
      Hive.box('mybox').put('habits', habits);
    });
  }

  void _addHabit() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String subtitle = '';
        return AlertDialog(
          title: const Text('Add New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Habit Name'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => subtitle = value,
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
                if (title.isNotEmpty) {
                  setState(() {
                    habits.add(Habit(
                      title: title,
                      subtitle: subtitle,
                    ));
                    Hive.box('mybox').put('habits', habits);
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

  @override
  Widget build(BuildContext context) {
    final activeHabits = habits.where((habit) => !habit.isCompleted).toList();
    final completedHabits = habits.where((habit) => habit.isCompleted).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Active Habits'),
                Tab(text: 'Completed'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHabitsList(activeHabits),
                  _buildHabitsList(completedHabits),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> habitsList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: habitsList.length,
              itemBuilder: (context, index) {
                final habit = habitsList[index];
                final originalIndex = habits.indexOf(habit);
                return Dismissible(
                  key: Key(habit.title),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground:
                  habit.isCompleted?
                  Container(
                    color: Colors.amber,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  )
                      :
                  Container(
                    color: Colors.green,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _deleteHabit(originalIndex);
                    }
                  },
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _toggleHabit(originalIndex);
                      return false;
                    }
                    return true;
                  },
                  child: _buildHabitCard(
                    habit.title,
                    habit.subtitle,
                    Icons.circle,
                    habit.isCompleted,
                    () => _toggleHabit(originalIndex),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted,
    VoidCallback onToggle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 20,color: isCompleted?Colors.lightGreen:Colors.amber,),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Checkbox(
          value: isCompleted,
          onChanged: (_) => onToggle(),
        ),
      ),
    );
  }
}
