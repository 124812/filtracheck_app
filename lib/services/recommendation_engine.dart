// Extended models and RecommendationEngine to implement the full engine behaviour
// described in your Streamlit spec. This file is pure Dart and depends only on
// your existing models (Chemical, ChemicalSelection). It replaces/extends the
// earlier FilterRecommendation model and RecommendationEngine implementation.
//
// Paste into your project, replacing the previous RecommendationEngine and
// FilterRecommendation definitions.

import '../models/chemical.dart';

class FilterRecommendation {
  final Map<String, double> combinedTotals; // CF-A ... CF-H totals
  final List<String> distinctFilters; // e.g. ['A','C']
  final String? mainFilter; // 'A' (no 'CF-' prefix)
  final String? secondaryFilter;
  final bool isDucted; // final recommendation (true => ducted)
  final List<String> reasons; // e.g. ['Heating involved', '> 2 distinct filters required (3)']

  // Special flags derived from per-chemical special filters
  final bool anyEscoFlag; // ESCO present in any chemical
  final bool anyBangFlag; // '!' present in any chemical

  // Ducted follow-up helpers (engine provides these so UI can render the follow-up flow)
  // If final recommendation is ducted, these fields help the UI present questions and results.
  final bool ductedDecisionNeeded; // true if >1 specific-use boxes checked (requires preference)
  final bool ductedProvidedSingleModel; // true if exactly one specific-use was selected and maps to a model
  final List<String> ductedSuggestedModels; // concrete model codes (e.g. ['EFP'], ['EFQ','EFA-M']) when determinable
  final List<String> ductedPreferenceOptions; // fallback preference options labels

  // Export-friendly map of ducted-specific boolean answers (if provided to engine)
  final Map<String, bool>? ductedSpecificAnswers;

  const FilterRecommendation({
    required this.combinedTotals,
    required this.distinctFilters,
    required this.mainFilter,
    required this.secondaryFilter,
    required this.isDucted,
    required this.reasons,
    required this.anyEscoFlag,
    required this.anyBangFlag,
    required this.ductedDecisionNeeded,
    required this.ductedProvidedSingleModel,
    required this.ductedSuggestedModels,
    required this.ductedPreferenceOptions,
    this.ductedSpecificAnswers,
  });
}

class RecommendationEngine {
  // Public API: same core methods plus extended calculateRecommendations
  static Map<String, double> buildFilterRecommendation(Chemical chemical) {
    return chemical.filterQuantities;
  }

  static List<Chemical> findChemical(List<Chemical> chemicals, String query) {
    final q = query.toLowerCase().trim();
    final exactMatches = chemicals.where((chemical) =>
    chemical.name.toLowerCase() == q ||
        chemical.casNumber.toLowerCase() == q).toList();

    if (exactMatches.isNotEmpty) return exactMatches;

    return chemicals.where((chemical) =>
        chemical.name.toLowerCase().contains(q)).toList();
  }

  /// Extended calculateRecommendations
  ///
  /// - [selections]: list of ChemicalSelection (quantity in mL, frequency per month)
  /// - [heatingInvolved]: whether heating checkbox is set
  /// - [forceDuctlessOverride]: optional UI-provided override (true => force ductless even if defaults indicate ducted)
  /// - [ductedFollowupAnswers]: optional map of follow-up boolean answers when final is ducted:
  ///     {
  ///       'perchloric': true/false,
  ///       'flammable': true/false,
  ///       'radioactive': true/false,
  ///       'trace': true/false,
  ///       'digestion': true/false,
  ///       'tall': true/false,
  ///     }
  ///
  /// Returns an instance of FilterRecommendation that contains:
  /// - combined totals for CF-A..CF-H
  /// - distinct filters
  /// - main & secondary filter (by dominance scoring)
  /// - ducted/ductless decision and reasons
  /// - flags for ESCO / '!' special filters
  /// - ducted follow-up suggested models or indicators for UI
  static FilterRecommendation calculateRecommendations(
      List<ChemicalSelection> selections,
      bool heatingInvolved, {
        bool forceDuctlessOverride = false,
        Map<String, bool>? ductedFollowupAnswers,
      }) {
    const filterCols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    // init
    final combinedTotals = <String, double>{for (var c in filterCols) c: 0.0};
    final filterOccurrence = <String, int>{for (var c in filterCols) c: 0};
    final weightedSumQF = <String, double>{for (var c in filterCols) c: 0.0};

    var anyEscoFlag = false;
    var anyBangFlag = false;

    // accumulate per selection
    for (final sel in selections) {
      final qf = sel.quantity * sel.frequency; // mL * per month
      final fq = sel.chemical.filterQuantities;
      for (final entry in fq.entries) {
        final filter = entry.key;
        final qty = entry.value;
        combinedTotals[filter] = (combinedTotals[filter] ?? 0) + qty;
        filterOccurrence[filter] = (filterOccurrence[filter] ?? 0) + 1;
        weightedSumQF[filter] = (weightedSumQF[filter] ?? 0) + qf;
      }

      // special filters
      if (sel.chemical.specialFilters.contains('ESCO')) anyEscoFlag = true;
      if (sel.chemical.specialFilters.contains('!')) anyBangFlag = true;
    }

    // cleanup zeros
    combinedTotals.removeWhere((k, v) => v == 0 || v == 0.0);

    // distinct filters
    final distinctFilters = filterOccurrence.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList()
      ..sort();

    final numDistinct = distinctFilters.length;

    // dominance ranking:
    // score = (Σ qf for chemicals requiring filter) * (number of chemicals requiring filter)
    final ranking = <Map<String, dynamic>>[];
    for (final k in distinctFilters) {
      final n = filterOccurrence[k] ?? 0;
      final s = weightedSumQF[k] ?? 0.0;
      final score = s * n;
      final totalQty = combinedTotals[k] ?? 0.0;
      ranking.add({
        'filter': k,
        'score': score,
        'count': n,
        'sum': s,
        'totalQty': totalQty,
      });
    }

    ranking.sort((a, b) {
      // primary: score desc, then count desc, then sum desc, then alphabetical asc
      final sd = (b['score'] as double).compareTo(a['score'] as double);
      if (sd != 0) return sd;
      final cd = (b['count'] as int).compareTo(a['count'] as int);
      if (cd != 0) return cd;
      final su = (b['sum'] as double).compareTo(a['sum'] as double);
      if (su != 0) return su;
      return (a['filter'] as String).compareTo(b['filter'] as String);
    });

    final mainFilter = ranking.isNotEmpty ? ranking[0]['filter'] as String : null;
    final secondaryFilter = ranking.length > 1 ? ranking[1]['filter'] as String : null;

    // Decide default ducted/ductless
    var defaultIsDucted = false;
    final reasons = <String>[];
    if (heatingInvolved) {
      defaultIsDucted = true;
      reasons.add('Heating involved');
    }
    if (numDistinct > 2) {
      defaultIsDucted = true;
      reasons.add('> 2 distinct filters required ($numDistinct)');
    }

    // Special cases force ducted: ESCO or '!' should strongly suggest contacting ESCO / ducted only
    if (anyEscoFlag) {
      // keep as info; don't automatically force final ducted here but add reason
      reasons.add('ESCO flag');
    }
    if (anyBangFlag) {
      reasons.add('ESCO distributor / special handling required ("!" flag)');
    }

    // Final ducted decision: if defaultIsDucted and not overridden to force ductless by UI
    final finalDucted = defaultIsDucted && !forceDuctlessOverride;

    // Ducted follow-up flow
    // Map of follow-up answers expected keys: perchloric, flammable, radioactive, trace, digestion, tall
    // If finalDucted is true, compute suggested ducted models based on provided answers (if any).
    final ductedSuggestedModels = <String>[];
    var ductedDecisionNeeded = false;
    var ductedProvidedSingleModel = false;
    const preferenceOptions = <String>['EFD-A', 'EFD-B', 'EFA', 'EFH'];

    if (finalDucted) {
      // If followup answers provided, evaluate them
      if (ductedFollowupAnswers != null && ductedFollowupAnswers.isNotEmpty) {
        // collect checked items
        final picked = <String>[];
        if (ductedFollowupAnswers['perchloric'] == true) picked.add('EFP');
        if (ductedFollowupAnswers['flammable'] == true) picked.add('EFA-XP');
        if (ductedFollowupAnswers['radioactive'] == true) picked.add('EFI');
        if (ductedFollowupAnswers['trace'] == true) picked.add('PPH');
        if (ductedFollowupAnswers['digestion'] == true) picked.add('EFQ/EFA-M');
        if (ductedFollowupAnswers['tall'] == true) picked.add('EFF');

        if (picked.length == 1) {
          // single specific model
          ductedSuggestedModels.add(picked.first);
          ductedProvidedSingleModel = true;
        } else if (picked.length > 1) {
          // ambiguous -> require user to pick one preference option
          ductedDecisionNeeded = true;
        } else {
          // none picked -> engine should present preference options (fallback)
          // ductedSuggestedModels remains empty; UI should present preferenceOptions
        }
      } else {
        // No followup answers provided yet; UI should show follow-up choices and fallback preference options
      }
    }

    // Build and return FilterRecommendation
    return FilterRecommendation(
      combinedTotals: Map<String, double>.from(combinedTotals),
      distinctFilters: List<String>.from(distinctFilters),
      mainFilter: mainFilter,
      secondaryFilter: secondaryFilter,
      isDucted: finalDucted,
      reasons: List<String>.from(reasons),
      anyEscoFlag: anyEscoFlag,
      anyBangFlag: anyBangFlag,
      ductedDecisionNeeded: ductedDecisionNeeded,
      ductedProvidedSingleModel: ductedProvidedSingleModel,
      ductedSuggestedModels: List<String>.from(ductedSuggestedModels),
      ductedPreferenceOptions: List<String>.from(preferenceOptions),
      ductedSpecificAnswers: ductedFollowupAnswers != null ? Map<String,bool>.from(ductedFollowupAnswers) : null,
    );
  }
}
