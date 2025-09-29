import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Ductless Fume Hoods',
        'description': 'Explore our range of ductless fume hoods with advanced filtration',
        'icon': Icons.science_outlined,
        'items': ['Frontier Series', 'Explorer Series', 'Laboratory Series']
      },
      {
        'title': 'Filters & Cartridges',
        'description': 'Chemical filters for various applications',
        'icon': Icons.filter_alt_outlined,
        'items': ['CF-A Series', 'CF-B Series', 'CF-C Series', 'HEPA Filters']
      },
      {
        'title': 'Accessories',
        'description': 'Complementary products and accessories',
        'icon': Icons.build_outlined,
        'items': ['Monitoring Systems', 'Safety Equipment', 'Maintenance Kits']
      },
      {
        'title': 'Ducted Fume Hoods',
        'description': 'Traditional ducted fume hood solutions',
        'icon': Icons.air_outlined,
        'items': ['EFD Series', 'EFA Series', 'EFP Series']
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Catalog',
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
              'Browse Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore our comprehensive range of laboratory safety equipment and filtration solutions.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ...categories.map((category) => _buildCategoryCard(
              context,
              category['title'] as String,
              category['description'] as String,
              category['icon'] as IconData,
              category['items'] as List<String>,
            )),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      List<String> items,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0D47A1)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: Color(0xFF1976D2)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('View details for $item')),
                          );
                        },
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}