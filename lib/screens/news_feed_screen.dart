import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class NewsfeedScreen extends StatelessWidget {
  const NewsfeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsItems = [
      {
        'title': 'INTO THE GENOME: COVID-19 DIAGNOSTICS',
        'date': 'March 15, 2024',
        'category': 'Research',
        'preview': 'Controlling the spread of a disease outbreak requires an accurate understanding of the causative agent, transmission mechanism, patient profiles, and available interventions...',
      },
      {
        'title': 'NEW FILTRATION TECHNOLOGY BREAKTHROUGH',
        'date': 'March 10, 2024',
        'category': 'Technology',
        'preview': 'Esco announces revolutionary advancement in activated carbon filtration technology, improving chemical capture efficiency by 40%...',
      },
      {
        'title': 'LABORATORY SAFETY GUIDELINES UPDATE',
        'date': 'March 5, 2024',
        'category': 'Safety',
        'preview': 'Updated international guidelines for laboratory fume hood safety and chemical handling procedures now available...',
      },
      {
        'title': 'SUSTAINABLE LAB PRACTICES',
        'date': 'February 28, 2024',
        'category': 'Environment',
        'preview': 'How ductless fume hoods contribute to energy-efficient and environmentally responsible laboratory operations...',
      },
      {
        'title': 'FILTER MAINTENANCE BEST PRACTICES',
        'date': 'February 20, 2024',
        'category': 'Maintenance',
        'preview': 'Expert tips for extending filter life and maintaining optimal performance in your ductless fume hood systems...',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Newsfeed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Updates',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stay informed about the latest developments in laboratory safety and filtration technology.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ...newsItems.map((item) => _buildNewsCard(
              context,
              item['title'] as String,
              item['date'] as String,
              item['category'] as String,
              item['preview'] as String,
            )),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildNewsCard(
      BuildContext context,
      String title,
      String date,
      String category,
      String preview,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preview,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening: $title')),
                  );
                },
                child: const Text(
                  'Read More →',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}