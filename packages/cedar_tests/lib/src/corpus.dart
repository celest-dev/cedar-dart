import 'package:cedar_tests/src/corpus_types.dart';

import 'generated/corpus_registry.dart';

export 'corpus_types.dart';

/// All corpus tests bundled with the Cedar Dart packages.
final Map<String, CedarTest> cedarCorpusTests = Map.unmodifiable({
  for (final entry in generatedCorpusLoaders.entries) entry.key: entry.value(),
});
