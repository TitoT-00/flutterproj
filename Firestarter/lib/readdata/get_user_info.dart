import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../inside/event.dart';

class getUserInfo extends StatelessWidget{
  final String documentId;

  getUserInfo({required this.documentId});

  Future<String> getCurrentUID() async{
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    return (await _firebaseAuth.currentUser!).uid;
  }

  Future getCurrentUser() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    return await _firebaseAuth.currentUser!;
  }


  @override
  Widget build(BuildContext context){

    //get the collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: ((context, snapshot){
        if(snapshot.connectionState == ConnectionState.done)  {
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String,dynamic>;

          return Text('Welcome: ${data['display name']}');
        }
        return Text('loading...');
      }),
    );
  }
}