import 'dart:math' as math;

import '../models/item.dart';
import 'search_result.dart';

class InventorySearchEngine {
  const InventorySearchEngine();

  List<SearchResult> search({
    required String query,
    required List<Item> items,
  }) {
    final normalizedQuery = _normalize(query);
    final queryTokens = _tokens(normalizedQuery);
    if (queryTokens.isEmpty) {
      return const [];
    }

    final results = <SearchResult>[];
    for (final item in items.where((item) => item.isOwned)) {
      final score = _scoreItem(item, normalizedQuery, queryTokens);
      if (score.score > 0) {
        results.add(score);
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  SearchResult _scoreItem(
    Item item,
    String normalizedQuery,
    List<String> queryTokens,
  ) {
    final weightedFields = <_WeightedField>[
      _WeightedField('Name', item.name, 8),
      _WeightedField('Alternative Namen', item.alternativeNames.join(' '), 6),
      _WeightedField('Kategorie', item.category, 4),
      _WeightedField('Fähigkeiten', item.capabilities.join(' '), 7),
      _WeightedField('Eigenschaften', item.properties.join(' '), 4),
      _WeightedField('Tags', item.tags.join(' '), 5),
      _WeightedField('Marke', item.brand, 3),
      _WeightedField('Beschreibung', item.description, 2),
    ];

    var score = 0.0;
    final reasons = <String>[];

    for (final field in weightedFields) {
      final normalizedField = _normalize(field.text);
      final fieldTokens = _tokens(normalizedField);
      if (normalizedField.isEmpty) {
        continue;
      }

      if (normalizedField.contains(normalizedQuery)) {
        score += field.weight * 2.4;
        reasons.add('${field.name}: exakter Treffer');
      }

      for (final queryToken in queryTokens) {
        for (final fieldToken in fieldTokens) {
          if (fieldToken == queryToken) {
            score += field.weight;
            reasons.add('${field.name}: $queryToken');
          } else if (fieldToken.contains(queryToken) ||
              queryToken.contains(fieldToken)) {
            score += field.weight * 0.6;
          } else if (_similarity(fieldToken, queryToken) >= 0.72) {
            score += field.weight * 0.45;
            reasons.add('${field.name}: ähnlich zu $queryToken');
          }
        }
      }
    }

    return SearchResult(
      item: item,
      score: double.parse(score.toStringAsFixed(2)),
      reasons: reasons.toSet().take(4).toList(),
    );
  }

  String _normalize(String input) {
    final lower = input.toLowerCase();
    final replacements = {
      'ä': 'ae',
      'ö': 'oe',
      'ü': 'ue',
      'ß': 'ss',
      '-': ' ',
      '_': ' ',
      '/': ' ',
    };
    var output = lower;
    replacements.forEach((from, to) {
      output = output.replaceAll(from, to);
    });
    return output.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').trim();
  }

  List<String> _tokens(String input) {
    const stopWords = {
      'ich',
      'zum',
      'zur',
      'der',
      'die',
      'das',
      'ein',
      'eine',
      'etwas',
      'ding',
      'womit',
      'mit',
      'und',
      'oder',
      'im',
      'in',
      'am',
    };
    return input
        .split(RegExp(r'\s+'))
        .where((token) => token.length > 1 && !stopWords.contains(token))
        .toList();
  }

  double _similarity(String a, String b) {
    if ((a.length - b.length).abs() > 4) {
      return 0;
    }
    final maxLength = math.max(a.length, b.length);
    if (maxLength == 0) {
      return 1;
    }
    return 1 - (_levenshtein(a, b) / maxLength);
  }

  int _levenshtein(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (index) => index);
    final current = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final insert = current[j] + 1;
        final delete = previous[j + 1] + 1;
        final replace = previous[j] + (a[i] == b[j] ? 0 : 1);
        current[j + 1] = math.min(insert, math.min(delete, replace));
      }
      previous.setAll(0, current);
    }
    return previous[b.length];
  }
}

class _WeightedField {
  const _WeightedField(this.name, this.text, this.weight);

  final String name;
  final String text;
  final double weight;
}
