// import 'package:flutter/material.dart';
// import '../auth/main_page.dart';
// class Splash extends StatelessWidget{
//   const Splash({Key? key}) : super(key: key);
//
//   @override
//   void initState(){
//     super.initState();
//     _navigatetohome();
//   }
//
//   _navigatetohome()async{
//     await Future.delayed(Duration(milliseconds: 1500),(){});
//     Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MainPage(),))
//
//   }
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       body: Center(
//         child: Container(
//           child: Image.asset("blueflame.png"),
//         ),
//       ),
//     );
//   }
// }