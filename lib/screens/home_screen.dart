import 'package:flutter/material.dart';
import 'faq_screens.dart';
import 'chemical_calculator_screen.dart';
import '../widgets/nav_button.dart';
import '../widgets/news_item.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    NavButton(
                        text: 'Calculator',
                        icon: Icons.calculate,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ChemicalCalculatorScreen()),
                          );
                        }
                    ),
                    NavButton(
                        text: 'Chemical',
                        icon: Icons.science,
                        onTap: () {}
                    ),
                    NavButton(
                        text: 'Catalog',
                        icon: Icons.list_alt,
                        onTap: () {}
                    ),
                    NavButton(
                        text: 'Contact',
                        icon: Icons.contact_page,
                        onTap: () {}
                    ),
                    NavButton(
                        text: 'Newsfeed',
                        icon: Icons.feed,
                        onTap: () {}
                    ),
                    NavButton(
                        text: 'FAQ',
                        icon: Icons.help,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TopicalFaqScreen()),
                          );
                        }
                    ),
                    NavButton(
                        text: 'Dictionary',
                        icon: Icons.book,
                        onTap: () {}
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // About the App section
              const Text(
                'About the App',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esco\'s FiltraCheck™ is a free chemical assessment guide dedicated to help you select the right filter for your intended use.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Newsfeed section
              const Text(
                'Newsfeed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              NewsItem(title: 'INTO THE GENOME: COVID-19 DIAGNOSTICS'),
              NewsItem(title: 'INTO THE GENOME: COVID-19 DIAGNOSTICS'),
              NewsItem(title: 'INTO THE GENOME: COVID-19 DIAGNOSTICS'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}