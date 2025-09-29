import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/chemical.dart';
import '../services/csv_parser.dart';
import '../widgets/bottom_nav_bar.dart';

class ChemicalListScreen extends StatefulWidget {
  const ChemicalListScreen({super.key});

  @override
  State<ChemicalListScreen> createState() => _ChemicalListScreenState();
}

class _ChemicalListScreenState extends State<ChemicalListScreen> {
  List<Chemical> _chemicals = [];
  List<Chemical> _filteredChemicals = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _filterBy = 'All'; // All, A, B, C, D, E, F, G, H

  @override
  void initState() {
    super.initState();
    _loadChemicals();
    _searchController.addListener(_filterChemicals);
  }

  Future<void> _loadChemicals() async {
    setState(() => _isLoading = true);
    try {
      final byteData = await rootBundle.load('assets/chemical_guide.csv');
      final bytes = byteData.buffer.asUint8List();
      String data;
      try {
        data = utf8.decode(bytes);
      } on FormatException {
        try {
          data = latin1.decode(bytes);
        } on FormatException {
          data = ascii.decode(bytes);
        }
      }
      final chemicals = await CSVParser.loadChemicalGuide(data);
      setState(() {
        _chemicals = chemicals;
        _filteredChemicals = chemicals;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading chemicals: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _filterChemicals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChemicals = _chemicals.where((c) {
        final matchesSearch = c.name.toLowerCase().contains(query) ||
            c.casNumber.toLowerCase().contains(query) ||
            c.formula.toLowerCase().contains(query);

        if (_filterBy == 'All') return matchesSearch;

        return matchesSearch && c.filterQuantities.containsKey(_filterBy);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chemical Database',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, CAS, or formula',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      ...'ABCDEFGH'.split('').map((f) => _buildFilterChip(f)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Found ${_filteredChemicals.length} chemicals',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredChemicals.isEmpty
                ? const Center(child: Text('No chemicals found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredChemicals.length,
              itemBuilder: (context, index) {
                final chemical = _filteredChemicals[index];
                return _buildChemicalCard(chemical);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _filterBy == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter == 'All' ? 'All' : 'CF-$filter'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterBy = filter;
            _filterChemicals();
          });
        },
        selectedColor: const Color(0xFF0D47A1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildChemicalCard(Chemical chemical) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          chemical.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('CAS: ${chemical.casNumber} | Formula: ${chemical.formula}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chemical.filterQuantities.isNotEmpty) ...[
                  const Text(
                    'Required Filters:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chemical.filterQuantities.entries.map((e) {
                      return Chip(
                        label: Text('CF-${e.key}: ${e.value}'),
                        backgroundColor: const Color(0xFF1976D2),
                        labelStyle: const TextStyle(color: Colors.white),
                      );
                    }).toList(),
                  ),
                ],
                if (chemical.specialFilters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Special Filters:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: chemical.specialFilters.map((f) {
                      return Chip(
                        label: Text(f),
                        backgroundColor: Colors.orange,
                        labelStyle: const TextStyle(color: Colors.white),
                      );
                    }).toList(),
                  ),
                ],
                if (chemical.combinationNote != null &&
                    chemical.combinationNote!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Note: ${chemical.combinationNote}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}