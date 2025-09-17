import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String title;

  const NewsItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Controlling the spread of a disease outbreak requires an accurate understanding of the causative agent, transmission mechanism, patient profiles, and available interventions. Unexplained respiratory outbreaks including the recent COVID-19 disease outbreak,....',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Read More',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}