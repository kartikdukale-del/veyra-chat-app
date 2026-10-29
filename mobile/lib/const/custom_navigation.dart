import 'package:flutter/material.dart';

class CustomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>onTap;

  const CustomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
       currentIndex: currentIndex,
       onTap: onTap,
       type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
       selectedItemColor: Colors.blue,
       
      elevation: 0,
      
       unselectedItemColor: Colors.grey,
      items: [
      
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
    );
  }
}