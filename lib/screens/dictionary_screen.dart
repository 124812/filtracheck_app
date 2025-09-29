import 'package:flutter/material.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredTerms = [];

  final List<Map<String, String>> _terms = [
    {
      'term': 'Activated Carbon',
      'definition': 'A form of carbon processed to have small, low-volume pores that increase the surface area available for adsorption or chemical reactions.',
    },
    {
      'term': 'CAS Number',
      'definition': 'Chemical Abstracts Service Registry Number - a unique numerical identifier assigned to every chemical substance.',
    },
    {
      'term': 'Ductless Fume Hood',
      'definition': 'A self-contained workstation that filters hazardous fumes and particulates from the air and recirculates clean air back into the laboratory.',
    },
    {
      'term': 'Ducted Fume Hood',
      'definition': 'A ventilated workstation that exhausts contaminated air to the outside through a duct system.',
    },
    {
      'term': 'HEPA Filter',
      'definition': 'High-Efficiency Particulate Air filter - removes at least 99.97% of particles 0.3 micrometers in diameter.',
    },
    {
      'term': 'Filter Cartridge',
      'definition': 'Replaceable filtration media designed to remove specific chemical vapors or particles from contaminated air.',
    },
    {
      'term': 'Face Velocity',
      'definition': 'The average velocity of air drawn through the sash opening of a fume hood, typically measured in feet per minute (FPM).',
    },
    {
      'term': 'Volatile Organic Compound (VOC)',
      'definition': 'Organic chemicals that have a high vapor pressure at room temperature and easily evaporate into the air.',
    },
    {
      'term': 'Perchloric Acid',
      'definition': 'A strong acid used in laboratories that requires specialized fume hoods due to its explosive nature when exposed to organic materials.',
    },
    {
      'term': 'Laboratory Airflow',
      'definition': 'The controlled movement of air within a laboratory environment to maintain safety and containment.',
    },
    {
      'term': 'Molecular Formula',
      'definition': 'A representation of a chemical substance using element symbols and numerical subscripts.',
    },
    {
      'term': 'PPE',
      'definition': 'Personal Protective Equipment - equipment worn to minimize exposure to hazards.',
    },
    {
      'term': 'Adsorption',
      'definition': 'The adhesion of atoms, ions, or molecules from a gas, liquid, or dissolved solid to a surface.',
    },
    {
      'term': 'Breakthrough',
      'definition': 'The point at which a filter can no longer effectively remove contaminants from the air stream.',
    },
    {
      'term': 'Chemical Resistance',
      'definition': 'The ability of a material to withstand contact with chemicals without deterioration.',
    },
    {
      'term': 'Containment',
      'definition': 'The process of keeping hazardous materials within a defined area to prevent contamination.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredTerms = _terms;
    _searchController.addListener(_filterTerms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTerms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTerms = _terms.where((term) {
        return term['term']!.toLowerCase().contains(query) ||
            term['definition']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dictionary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laboratory Terms',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Search and explore definitions of common laboratory and filtration terms.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search terms',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTerms.isEmpty
                ? const Center(
              child: Text(
                'No terms found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredTerms.length,
              itemBuilder: (context, index) {
                final term = _filteredTerms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      term['term']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          term['definition']!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

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
              Navigator.of(context).popUntil((route) => route.isFirst);
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