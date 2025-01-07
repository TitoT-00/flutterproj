import 'package:flutter/material.dart';
import 'package:myapp/util/buttons.dart';

class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      backgroundColor: Colors.red[400],
        content:SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //get user input
              TextField(controller: controller,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:"Add a task"
                ),
              ),

              //buttons -> save and Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //save button
                  buttons(text: "Save", onPressed: onSave),

                  const SizedBox(width: 10),
                  //cancel button
                  buttons(text: "Cancel", onPressed: onCancel),


                ],
              ),
            ],
          ),

        ),
    );
  }
}