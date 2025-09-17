class Chemical {
  final String name;
  final String casNumber;
  final String formula;
  final Map<String, double> filterQuantities; // A-H filters
  final List<String> specialFilters; // HEPA, ESCO, !
  final String? combinationNote;
  final String? nonDuctlessProducts;

  Chemical({
    required this.name,
    required this.casNumber,
    required this.formula,
    required this.filterQuantities,
    required this.specialFilters,
    this.combinationNote,
    this.nonDuctlessProducts,
  });

  factory Chemical.fromMap(Map<String, dynamic> map) {
    final filterQuantities = <String, double>{};
    final specialFilters = <String>[];

    // Parse A-H filters
    const filterCols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    for (var col in filterCols) {
      if (map[col] != null && map[col] != '' && map[col] != 'NaN') {
        final value = double.tryParse(map[col].toString());
        if (value != null && value > 0) {
          filterQuantities[col] = value;
        }
      }
    }

    // Parse special filters
    const specialCols = ['HEPA', 'ESCO', '!'];
    for (var col in specialCols) {
      if (map[col] != null && map[col] != '' && map[col] != 'NaN') {
        final value = double.tryParse(map[col].toString());
        if (value != null && value == 1.0) {
          specialFilters.add(col);
        }
      }
    }

    return Chemical(
      name: map['CHEMICAL NAME']?.toString() ?? '',
      casNumber: map['CAS No.']?.toString() ?? '',
      formula: map['FORMULA']?.toString() ?? '',
      filterQuantities: filterQuantities,
      specialFilters: specialFilters,
      combinationNote: map['COMBINATION']?.toString(),
      nonDuctlessProducts: map['NON DUCTLESS RECOMMENDED PRODUCTS']?.toString(),
    );
  }
}

class ChemicalSelection {
  final Chemical chemical;
  final double quantity; // mL
  final double frequency; // per month

  ChemicalSelection({
    required this.chemical,
    required this.quantity,
    required this.frequency,
  });
}

class FilterRecommendation {
  final Map<String, double> combinedTotals;
  final List<String> distinctFilters;
  final String? mainFilter;
  final String? secondaryFilter;
  final bool isDucted;
  final List<String> reasons;

  FilterRecommendation({
    required this.combinedTotals,
    required this.distinctFilters,
    this.mainFilter,
    this.secondaryFilter,
    required this.isDucted,
    required this.reasons,
  });
}