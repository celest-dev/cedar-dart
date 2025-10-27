import 'dart:convert';
import 'dart:io';

import 'package:cedar/cedar.dart';
import 'package:cedar_tests/src/corpus_types.dart';
import 'package:dart_style/dart_style.dart';
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
  final testData = <String, CedarTest>{};
  for (final testFile in testFiles) {
    final relativePath = p.relative(testFile.path, from: testRoot);
    final defaultName = p.basenameWithoutExtension(testFile.path);
    final name =
        relativePath.startsWith('corpus-tests/') ||
            relativePath.startsWith('corpus_tests/')
        ? defaultName
        : _manualTestName(relativePath);
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
  await _writeGeneratedCorpus(testData);
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

Future<void> _writeGeneratedCorpus(Map<String, CedarTest> tests) async {
  final generatedDir = Directory.fromUri(
    Platform.script.resolve('../lib/src/generated/'),
  );
  if (generatedDir.existsSync()) {
    generatedDir.deleteSync(recursive: true);
  }
  generatedDir.createSync(recursive: true);

  final casesDir = Directory(p.join(generatedDir.path, 'corpus'))
    ..createSync(recursive: true);

  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );
  final registryImports = <String>[];
  final registryEntries = StringBuffer();
  final excludedOnWeb = <String>[];

  var index = 0;
  for (final entry in tests.entries) {
    final testName = entry.key;
    final test = entry.value;
    final paddedIndex = index.toString().padLeft(5, '0');
    final fileStem = '${paddedIndex}_${_sanitizeFileName(testName)}';
    final fileName = '$fileStem.dart';
    final alias = 'case$index';
    final serialized = test.toJson();
    final hasUnsafeNumbers = _containsUnsafeNumber(serialized);
    if (hasUnsafeNumbers) {
      excludedOnWeb.add(testName);
    }
    final jsonLiteral = json.encode(serialized);
    final rawJsonLiteral = _asDartStringLiteral(jsonLiteral);
    final fileBuffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// ignore_for_file: file_names, unnecessary_string_escapes')
      ..writeln()
      ..writeln("import 'dart:convert';")
      ..writeln()
      ..writeln("import 'package:cedar_tests/src/corpus_types.dart';")
      ..writeln()
      ..writeln('CedarTest load() {')
      ..writeln('  const String rawJson = $rawJsonLiteral;')
      ..writeln('  final Map<String, Object?> data =')
      ..writeln("      jsonDecode(rawJson) as Map<String, Object?>;")
      ..writeln('  return CedarTest.fromJson(data);')
      ..writeln('}');

    final formatted = formatter.format(fileBuffer.toString());
    final outputPath = p.join(casesDir.path, fileName);
    await File(outputPath).writeAsString(formatted);

    registryImports.add("import 'corpus/$fileName' as $alias;");
    if (hasUnsafeNumbers) {
      registryEntries
        // WASM is okay, only worried about JS
        ..writeln("  if (!kIsJsWeb)")
        ..writeln('    ${json.encode(testName)}: $alias.load,');
    } else {
      registryEntries.writeln('  ${json.encode(testName)}: $alias.load,');
    }

    index += 1;
  }

  final registryBuffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// ignore_for_file: file_names')
    ..writeln()
    ..writeln("import 'package:cedar_tests/src/corpus_types.dart';")
    ..writeln();

  for (final import in registryImports) {
    registryBuffer.writeln(import);
  }

  registryBuffer
    ..writeln()
    ..writeln('// Whether the code is running on JavaScript web platform.')
    ..writeln("const kIsJsWeb = bool.fromEnvironment('dart.library.html');")
    ..writeln()
    ..writeln('final Map<String, CedarTestLoader> generatedCorpusLoaders = {')
    ..write(registryEntries.toString())
    ..writeln('};')
    ..writeln();

  final registryPath = p.join(generatedDir.path, 'corpus_registry.dart');
  final formattedRegistry = formatter.format(registryBuffer.toString());
  await File(registryPath).writeAsString(formattedRegistry);

  print('Generated ${tests.length} corpus tests into ${generatedDir.path}');
  if (excludedOnWeb.isNotEmpty) {
    print(
      'Excluded ${excludedOnWeb.length} tests from web due to large numbers',
    );
  }
}

String _sanitizeFileName(String value) {
  var sanitized = value.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
  sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');
  sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
  if (sanitized.isEmpty) {
    sanitized = 'case';
  }
  if (sanitized.length > 64) {
    sanitized = sanitized.substring(0, 64);
  }
  return sanitized.toLowerCase();
}

String _asDartStringLiteral(String value) {
  final buffer = StringBuffer("'");
  for (final codeUnit in value.codeUnits) {
    switch (codeUnit) {
      case 0x27: // '
        buffer.write(r"\'");
        break;
      case 0x5C: // \
        buffer.write(r"\\");
        break;
      case 0x0A: // newline
        buffer.write(r"\n");
        break;
      case 0x0D: // carriage return
        buffer.write(r"\r");
        break;
      case 0x09: // tab
        buffer.write(r"\t");
        break;
      case 0x0C: // form feed
        buffer.write(r"\f");
        break;
      case 0x0B: // vertical tab
        buffer.write(r"\v");
        break;
      case 0x08: // backspace
        buffer.write(r"\b");
        break;
      case 0x24: // $
        buffer.write(r"\$");
        break;
      default:
        if (codeUnit < 0x20) {
          buffer
            ..write(r"\u")
            ..write(codeUnit.toRadixString(16).padLeft(4, '0'));
        } else {
          buffer.writeCharCode(codeUnit);
        }
    }
  }
  buffer.write("'");
  return buffer.toString();
}

bool _containsUnsafeNumber(Object? value) {
  if (value is num) {
    if (!value.isFinite) {
      return false;
    }
    return value.abs() > _jsMaxSafeInteger;
  }
  if (value is String) {
    for (final match in _unsafeNumberPattern.allMatches(value)) {
      final lexeme = match.group(0);
      if (lexeme == null) {
        continue;
      }
      try {
        final parsed = BigInt.parse(lexeme);
        if (parsed.abs() > _jsMaxSafeBigInt) {
          return true;
        }
      } on FormatException {
        // Ignore lexemes that are not valid integers.
      }
    }
    return false;
  }
  if (value is List) {
    for (final element in value) {
      if (_containsUnsafeNumber(element)) {
        return true;
      }
    }
    return false;
  }
  if (value is Map) {
    for (final element in value.values) {
      if (_containsUnsafeNumber(element)) {
        return true;
      }
    }
    return false;
  }
  return false;
}

const int _jsMaxSafeInteger = 9007199254740991; // 2^53 - 1

final BigInt _jsMaxSafeBigInt = BigInt.from(_jsMaxSafeInteger);

final RegExp _unsafeNumberPattern = RegExp(r'-?\d+');
