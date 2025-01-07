import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/data/database.dart';
import '../util/todo_tile.dart';
import '../util/dialog_box.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  //reference the hive box
  final _myBox = Hive.box('mybox');
  //create instances
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState(){
    //1st time opening with default setting
    if(_myBox.get("TODOLIST") == null){
      db.createInitialData();
    } else {
      //already opened
      db.loadData();
    }



    super.initState();

  }

  //text controller
  final _controller = TextEditingController();

  //checked was tapped
  void checkBoxChanged(bool? value, int index){
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();

  }

   //save task
   void saveNewTask()
   {
     setState(() {
       db.toDoList.add([ _controller.text, false]);
       _controller.clear();
     });
     Navigator.of(context).pop();
     db.updateDatabase();

   }

  //create a new task
  void createNewTask(){
     showDialog(
         context: context,
         builder: (context){
           return DialogBox(
             controller: _controller,
             onSave: saveNewTask,
             onCancel: () => Navigator.of(context).pop(),
           );
         },
     );
  }

  //delete Task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text('TO DO',
                  style: TextStyle(color: Colors.black,),),
        leading: IconButton(
          icon: const Icon(
              Icons.add,
          color: Colors.black),
          onPressed: createNewTask,
        ),
        backgroundColor: Colors.yellowAccent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index){
          return ToDoTile(
              taskName: db.toDoList[index][0],
              taskCompleted: db.toDoList[index][1],
              onChanged: (value) => checkBoxChanged(value,index),
            deleteFunction: (context) => deleteTask(index),
          );
        },

      ),
    );
  }
}