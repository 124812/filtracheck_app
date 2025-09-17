import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF0D47A1)),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.grey),
            onPressed: () {
              // Navigate to About screen
            },
          ),
        ],
      ),
    );
  }
}