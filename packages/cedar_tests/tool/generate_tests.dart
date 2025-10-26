import 'dart:convert';
import 'dart:io';

import 'package:cedar/cedar.dart';
import 'package:cedar_tests/src/corpus.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final tempDir = await Directory.systemTemp.createTemp('cedar_');
  final res = await Process.run('git', [
    'clone',
    'https://github.com/cedar-policy/cedar-integration-tests',
    '--single-branch',
    '.',
  ], workingDirectory: tempDir.path);
  if (res.exitCode != 0) {
    throw ProcessException(
      'git',
      ['clone'],
      'Failed to checkout Cedar: ${res.stdout}\n${res.stderr}',
      res.exitCode,
    );
  }
  final testRoot = tempDir.path;
  final corpusArchive = File(p.join(testRoot, 'corpus-tests.tar.gz'));
  if (corpusArchive.existsSync()) {
    final extractResult = await Process.run('tar', [
      '-xzf',
      corpusArchive.path,
      '-C',
      testRoot,
    ]);
    if (extractResult.exitCode != 0) {
      throw ProcessException(
        'tar',
        ['-xzf', corpusArchive.path, '-C', testRoot],
        'Failed to extract corpus tests: ${extractResult.stdout}\n${extractResult.stderr}',
        extractResult.exitCode,
      );
    }
  } else {
    print('Warning: no corpus-tests.tar.gz found at ${corpusArchive.path}');
  }
  final outputFile = File.fromUri(
    Directory.current.uri.resolve('lib/src/corpus.json'),
  );
  await outputFile.create(recursive: true);
  final testDirectories = <Directory>[
    Directory(p.join(testRoot, 'corpus-tests')),
    Directory(p.join(testRoot, 'corpus_tests')),
  ];
  final testFiles = <File>[];
  for (final dir in testDirectories) {
    if (!dir.existsSync()) {
      continue;
    }
    testFiles.addAll(
      dir.listSync().whereType<File>().where(_isTestDefinitionFile),
    );
  }
  final manualTestsDir = Directory(p.join(testRoot, 'tests'));
  if (manualTestsDir.existsSync()) {
    testFiles.addAll(
      manualTestsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where(_isTestDefinitionFile),
    );
  }
  testFiles.sort((a, b) => a.path.compareTo(b.path));
  const skipTests = {
    '57b7cfe0e1f8f9067164d7fb9f13e8b5da276ba5': 'Bad policy set',
    '38d1fcf284cdf4f1c53cb41c358b757918075cc0': 'Bad policy set',
    '7ca848ce836993ff836dd884591a6ae2ea97250e': 'Bad policy set',
    'c1b7e2298e77b88e1c25cf5efb2f048a18475ba3': 'Bad policy set',
    'a5f5eaf2971db213ce1b1716d0e088b80ae6959b': 'Values overflow on Web',
    'b3f1cf53e38305a659a1e2d048f9613d35acf097': 'Values overflow on Web',
    '22cca6533b288f8a0bc952f5777475b38eba2a54': 'Values overflow on Web',
    '95022c341ce992d2f23bd1594f5fafbd01ce6fd5': 'Values overflow on Web',
    'cfb3c703fbb3741577a9fb16f3199d65bd6d7757': 'Values overflow on Web',
    'ea66114dfde4a1054167ad3842044654009871f0': 'Values overflow on Web',
    'bd4aea79dc2fd325bef3fa0df4b811a6f746ef34': 'Values overflow on Web',
  };
  final testData = <String, CedarTest>{};
  for (final testFile in testFiles) {
    final relativePath = p.relative(testFile.path, from: testRoot);
    final defaultName = p.basenameWithoutExtension(testFile.path);
    final name =
        relativePath.startsWith('corpus-tests/') ||
            relativePath.startsWith('corpus_tests/')
        ? defaultName
        : _manualTestName(relativePath);
    if (skipTests[name] case final reason?) {
      print('Skipping $name: $reason');
      continue;
    }
    final json =
        jsonDecode(testFile.readAsStringSync()) as Map<String, Object?>;
    try {
      final test = _parseTest(json, name: name, repositoryRoot: testRoot);
      testData[name] = test;
    } on UnsupportedError catch (error) {
      print('Skipping $name: ${error.message}');
    } on FormatException catch (error) {
      print('Skipping $name: ${error.message}');
    } on ArgumentError catch (error) {
      throw ArgumentError.value(
        json,
        'json',
        'Invalid test data ($name): $error',
      );
    }
  }
  const encoder = JsonEncoder.withIndent('  ');
  await outputFile.writeAsString(
    encoder.convert(testData.map((k, v) => MapEntry(k, v.toJson()))),
  );
  final result = await Process.run(Platform.resolvedExecutable, [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  if (result.exitCode != 0) {
    throw ProcessException(
      'dart',
      ['build_runner', 'build', '--delete-conflicting-outputs'],
      '${result.stdout}\n${result.stderr}',
      result.exitCode,
    );
  }
}

bool _isTestDefinitionFile(File file) {
  final name = p.basename(file.path);
  return name.endsWith('.json') &&
      !name.endsWith('.entities.json') &&
      !name.startsWith('schema_') &&
      !name.startsWith('policies_') &&
      !name.startsWith('entities_');
}

String _manualTestName(String relativePath) {
  final withoutExtension = relativePath.replaceAll(RegExp(r'\.json$'), '');
  final sanitized = withoutExtension.replaceAll(RegExp(r'[\\/]'), '_');
  return 'manual_$sanitized';
}

CedarTest _parseTest(
  Map<String, Object?> json, {
  required String name,
  required String repositoryRoot,
}) {
  final schemaPath = _stringValue(json, 'schema');
  final schemaJson = _loadSchemaJson(repositoryRoot, schemaPath);
  final policiesPath = _stringValue(json, 'policies');
  final policiesFile = File(p.join(repositoryRoot, policiesPath));
  if (!policiesFile.existsSync()) {
    throw UnsupportedError('Missing policies file: $policiesPath');
  }
  final entitiesPath = _stringValue(json, 'entities');
  final entitiesFile = File(p.join(repositoryRoot, entitiesPath));
  if (!entitiesFile.existsSync()) {
    throw UnsupportedError('Missing entities file: $entitiesPath');
  }
  final shouldValidate =
      _boolValue(json, 'should_validate') ??
      _boolValue(json, 'shouldValidate') ??
      true;
  final queriesField = json['queries'] ?? json['requests'];
  if (queriesField is! List) {
    throw ArgumentError('Missing queries/requests array');
  }
  final queries = queriesField
      .map((entry) => _normalizeQuery(entry))
      .map((query) => CedarQuery.fromJson(query))
      .toList();
  final entitiesRaw = jsonDecode(entitiesFile.readAsStringSync());
  final entitiesJson = switch (entitiesRaw) {
    List list => list.cast<Object?>(),
    _ => throw UnsupportedError('Entities must be a JSON array: $entitiesPath'),
  };
  return CedarTest(
    name: name,
    schemaJson: schemaJson,
    policiesCedar: policiesFile.readAsStringSync(),
    shouldValidate: shouldValidate,
    entitiesJson: entitiesJson,
    queries: queries,
  );
}

Map<String, Object?> _normalizeQuery(Object? rawQuery) {
  if (rawQuery is! Map) {
    throw ArgumentError('Query entry must be an object: $rawQuery');
  }
  final query = Map<String, Object?>.from(rawQuery);
  final desc = query.remove('desc') ?? query.remove('description');
  if (desc is! String) {
    throw UnsupportedError('Missing query description');
  }
  final normalized = <String, Object?>{'desc': desc};
  final action = query['action'];
  if (action is! Map<String, Object?>) {
    throw UnsupportedError('Missing action for query "$desc"');
  }
  normalized['action'] = action;
  if (query['principal'] case final Map<String, Object?> principal) {
    normalized['principal'] = principal;
  }
  if (query['resource'] case final Map<String, Object?> resource) {
    normalized['resource'] = resource;
  }
  final context = query['context'];
  normalized['context'] = context is Map<String, Object?>
      ? context
      : <String, Object?>{};
  normalized['decision'] = _normalizeDecision(query['decision']);
  normalized['reasons'] = _stringList(query['reasons'] ?? query['reason']);
  normalized['errors'] = _stringList(query['errors']);
  return normalized;
}

String _normalizeDecision(Object? decision) {
  if (decision is String) {
    switch (decision.toLowerCase()) {
      case 'allow':
        return 'Allow';
      case 'deny':
        return 'Deny';
    }
    return decision;
  }
  throw UnsupportedError('Invalid decision value: $decision');
}

List<String> _stringList(Object? value) {
  if (value == null) {
    return const [];
  }
  if (value is String) {
    return [value];
  }
  if (value is List) {
    return value.map((entry) => entry.toString()).toList();
  }
  throw UnsupportedError('Expected list of strings, got $value');
}

String _stringValue(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw UnsupportedError('Missing string value for "$key"');
}

bool? _boolValue(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  return null;
}

Map<String, Object?> _loadSchemaJson(String repositoryRoot, String schemaPath) {
  final schemaFile = File(p.join(repositoryRoot, schemaPath));
  if (!schemaFile.existsSync()) {
    throw UnsupportedError('Missing schema file: $schemaPath');
  }
  final contents = schemaFile.readAsStringSync();
  if (schemaPath.endsWith('.json')) {
    final decoded = jsonDecode(contents);
    if (decoded is Map<String, Object?>) {
      return Map<String, Object?>.from(decoded);
    }
    throw UnsupportedError('Schema JSON must be an object: $schemaPath');
  }
  return CedarSchema.parse(contents).toJson();
}
