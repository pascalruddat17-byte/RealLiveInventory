import '../models/item.dart';

class SearchResult {
  const SearchResult({
    required this.item,
    required this.score,
    required this.reasons,
  });

  final Item item;
  final double score;
  final List<String> reasons;
}
