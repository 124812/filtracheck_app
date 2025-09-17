import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chemical.dart' hide FilterRecommendation;
import '../services/csv_parser.dart';
import '../services/recommendation_engine.dart';
import '../widgets/bottom_nav_bar.dart';

/// -------------------- Helper Widgets --------------------

class _ChemicalSearchPanel extends StatefulWidget {
  final List<Chemical> chemicals;
  final Function(Chemical) onChemicalSelected;

  const _ChemicalSearchPanel({
    required this.chemicals,
    required this.onChemicalSelected,
    super.key,
  });

  @override
  State<_ChemicalSearchPanel> createState() => __ChemicalSearchPanelState();
}

class __ChemicalSearchPanelState extends State<_ChemicalSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  List<Chemical> _filteredChemicals = [];

  @override
  void initState() {
    super.initState();
    _filteredChemicals = widget.chemicals;
    _searchController.addListener(_filterChemicals);
  }

  void _filterChemicals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChemicals = widget.chemicals
          .where((c) =>
      c.name.toLowerCase().contains(query) ||
          c.casNumber.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Chemicals',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _filteredChemicals.isEmpty
                  ? const Center(child: Text('No chemicals found'))
                  : ListView.builder(
                itemCount: _filteredChemicals.length,
                itemBuilder: (context, index) {
                  final chemical = _filteredChemicals[index];
                  return ListTile(
                    title: Text(chemical.name),
                    subtitle: Text('CAS: ${chemical.casNumber}'),
                    onTap: () => widget.onChemicalSelected(chemical),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _SelectedChemicalsPanel extends StatelessWidget {
  final List<ChemicalSelection> selectedChemicals;
  final Function(int, double) onQuantityChanged;
  final Function(int, double) onFrequencyChanged;
  final Function(int) onRemove;

  const _SelectedChemicalsPanel({
    required this.selectedChemicals,
    required this.onQuantityChanged,
    required this.onFrequencyChanged,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Chemicals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: selectedChemicals.isEmpty
                  ? const Center(child: Text('No chemicals selected'))
                  : ListView.builder(
                itemCount: selectedChemicals.length,
                itemBuilder: (context, index) {
                  final selection = selectedChemicals[index];
                  return _ChemicalSelectionCard(
                    selection: selection,
                    onQuantityChanged: (value) =>
                        onQuantityChanged(index, value),
                    onFrequencyChanged: (value) =>
                        onFrequencyChanged(index, value),
                    onRemove: () => onRemove(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChemicalSelectionCard extends StatelessWidget {
  final ChemicalSelection selection;
  final Function(double) onQuantityChanged;
  final Function(double) onFrequencyChanged;
  final VoidCallback onRemove;

  const _ChemicalSelectionCard({
    required this.selection,
    required this.onQuantityChanged,
    required this.onFrequencyChanged,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selection.chemical.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
            Text('CAS: ${selection.chemical.casNumber}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: selection.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity (mL)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = double.tryParse(value);
                      if (quantity != null) onQuantityChanged(quantity);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: selection.frequency.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Frequency/month',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final frequency = double.tryParse(value);
                      if (frequency != null) onFrequencyChanged(frequency);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  final FilterRecommendation recommendation;

  const _RecommendationPanel({required this.recommendation, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              recommendation.isDucted
                  ? 'Recommended: Ducted Fume Hood'
                  : 'Recommended: Ductless Fume Hood',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: recommendation.isDucted
                    ? Colors.green
                    : const Color(0xFF0D47A1),
              ),
            ),
            if (recommendation.reasons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reasons: ${recommendation.reasons.join("; ")}'),
            ],
            if (recommendation.combinedTotals.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Combined Totals:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Filter')),
                  DataColumn(label: Text('Total Qty')),
                ],
                rows: recommendation.combinedTotals.entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text('CF-${entry.key}')),
                    DataCell(Text(entry.value.toStringAsFixed(1))),
                  ]);
                }).toList(),
              ),
            ],
            if (!recommendation.isDucted) ...[
              const SizedBox(height: 16),
              const Text('Proposed Cartridge Set:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Main Filter: ${recommendation.mainFilter != null ? 'CF-${recommendation.mainFilter}' : '-'}'),
              Text(
                  'Secondary Filter: ${recommendation.secondaryFilter != null ? 'CF-${recommendation.secondaryFilter}' : '-'}'),
              if (recommendation.distinctFilters.length > 2) ...[
                const SizedBox(height: 8),
                Text(
                  'Warning: ${recommendation.distinctFilters.length - 2} additional filters required but not supported in ductless setup',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// -------------------- Main Screen --------------------

class ChemicalCalculatorScreen extends StatefulWidget {
  const ChemicalCalculatorScreen({super.key});

  @override
  State<ChemicalCalculatorScreen> createState() =>
      _ChemicalCalculatorScreenState();
}

class _ChemicalCalculatorScreenState extends State<ChemicalCalculatorScreen> {
  List<Chemical> _chemicals = [];
  List<ChemicalSelection> _selectedChemicals = [];
  bool _heatingInvolved = false;
  bool _isLoading = false;
  FilterRecommendation? _recommendation;

  @override
  void initState() {
    super.initState();
    _loadDefaultData();
  }

  Future<void> _loadDefaultData() async {
    setState(() => _isLoading = true);
    try {
      const csvData =
      '''CHEMICAL NAME,CAS No.,FORMULA,A,B,C,D,E,F,G,H,HEPA,ESCO,!,COMBINATION,NON DUCTLESS RECOMMENDED PRODUCTS
BENZENE,71-43-2,C6H6,1,,,,,,,,,,,,,
ACETONE,67-64-1,C3H6O,1,,,,,,,,,,,,,''';
      final chemicals = await CSVParser.loadChemicalGuide(csvData);
      setState(() => _chemicals = chemicals);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading default data: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadCSVFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final file = result.files.first;
        final contents = String.fromCharCodes(file.bytes!);
        final chemicals = await CSVParser.loadChemicalGuide(contents);
        setState(() {
          _chemicals = chemicals;
          _selectedChemicals.clear();
          _recommendation = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading file: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _useBuiltInCSV() async {
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
        _selectedChemicals.clear();
        _recommendation = null;
      });
    } catch (_) {
      await _loadDefaultData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Using default chemical data')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _calculateRecommendations() {
    if (_selectedChemicals.isEmpty) return;
    final recommendation = RecommendationEngine.calculateRecommendations(
        _selectedChemicals, _heatingInvolved);
    setState(() => _recommendation = recommendation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Chemical Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDatabaseCard(),
                const SizedBox(height: 16),
                _ChemicalSearchPanel(
                  chemicals: _chemicals,
                  onChemicalSelected: (chemical) {
                    setState(() {
                      _selectedChemicals.add(ChemicalSelection(
                          chemical: chemical, quantity: 100, frequency: 1));
                    });
                  },
                ),
                const SizedBox(height: 16),
                _SelectedChemicalsPanel(
                  selectedChemicals: _selectedChemicals,
                  onQuantityChanged: (i, value) {
                    setState(() {
                      _selectedChemicals[i] = ChemicalSelection(
                        chemical: _selectedChemicals[i].chemical,
                        quantity: value,
                        frequency: _selectedChemicals[i].frequency,
                      );
                    });
                  },
                  onFrequencyChanged: (i, value) {
                    setState(() {
                      _selectedChemicals[i] = ChemicalSelection(
                        chemical: _selectedChemicals[i].chemical,
                        quantity: _selectedChemicals[i].quantity,
                        frequency: value,
                      );
                    });
                  },
                  onRemove: (i) => setState(() => _selectedChemicals.removeAt(i)),
                ),
                const SizedBox(height: 16),
                _buildHeatingSwitch(),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _selectedChemicals.isEmpty
                        ? null
                        : _calculateRecommendations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Calculate Recommendations'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_recommendation != null)
                  _RecommendationPanel(recommendation: _recommendation!),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildDatabaseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chemical Database',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Loaded ${_chemicals.length} chemicals'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loadCSVFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Load Custom CSV'),
                ),
                ElevatedButton(
                  onPressed: _useBuiltInCSV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use Built-in CSV'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatingSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(child: Text('Does it involve Heating?')),
            Switch(
              value: _heatingInvolved,
              onChanged: (v) => setState(() => _heatingInvolved = v),
            ),
          ],
        ),
      ),
    );
  }
}
