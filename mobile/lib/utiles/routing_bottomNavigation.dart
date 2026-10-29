import 'package:app/const/custom_navigation.dart';
import 'package:app/view/chat_screen.dart';
import 'package:app/view/profile_screen.dart';
import 'package:app/view/search_screen.dart';
import 'package:app/view/setting_screen.dart';
import 'package:flutter/material.dart';


class RoutingBottomnavigation extends StatefulWidget {
  final int initialIndex;
  const RoutingBottomnavigation({super.key,this.initialIndex=0});

  @override
  State<RoutingBottomnavigation> createState() => _RoutingBottomnavigationState();
}

class _RoutingBottomnavigationState extends State<RoutingBottomnavigation> {
  late  int currentIndex;
  final screens=[
   ChatScreen(),
   SearchScreen(),
   ProfileScreen(),
   SettingScreen()
  ];

  @override
  void initState(){
      super.initState();
      currentIndex =widget.initialIndex;
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body:screens[currentIndex] ,
       bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 1
            )
          )
        ),
         child: CustomNavigation(currentIndex: currentIndex, onTap: (index){
          setState(() {
            currentIndex =index;
          });
               }),
       ),
    );
  }
}