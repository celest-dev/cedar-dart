import 'dart:convert';
import 'dart:io';

import 'package:cedar_tests/src/corpus.dart';
import 'package:path/path.dart' as p;

const cedarVersion = '3.4';

Future<void> main() async {
  final tempDir = await Directory.systemTemp.createTemp('cedar_');
  final res = await Process.run(
    'git',
    [
      'clone',
      'https://github.com/cedar-policy/cedar',
      '--single-branch',
      '--branch=release/$cedarVersion.x',
      '.',
    ],
    workingDirectory: tempDir.path,
  );
  if (res.exitCode != 0) {
    throw ProcessException(
      'git',
      ['clone'],
      'Failed to checkout Cedar: ${res.stdout}\n${res.stderr}',
      res.exitCode,
    );
  }
  final testRoot = p.join(
    tempDir.path,
    'cedar-integration-tests',
  );
  final outputFile = File.fromUri(
    Directory.current.uri.resolve('lib/src/corpus.json'),
  );
  await outputFile.create(recursive: true);
  final testFiles = Directory(p.join(testRoot, 'corpus_tests'))
      .listSync()
      .cast<File>()
      .where((file) {
    final name = p.basename(file.path);
    return name.endsWith('.json') &&
        !name.startsWith('schema_') &&
        !name.startsWith('policies_') &&
        !name.startsWith('entities_');
  });
  const skipTests = {
    '57b7cfe0e1f8f9067164d7fb9f13e8b5da276ba5': 'Bad policy set',
    '38d1fcf284cdf4f1c53cb41c358b757918075cc0': 'Bad policy set',
    '7ca848ce836993ff836dd884591a6ae2ea97250e': 'Bad policy set',
    'c1b7e2298e77b88e1c25cf5efb2f048a18475ba3': 'Bad policy set',
    'eff2557e80c650481f9850bc32dbd8a483ef8077':
        'ipaddr.isInRange unimplemented',
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
    final name = p.basenameWithoutExtension(testFile.path);
    if (skipTests[name] case final reason?) {
      print('Skipping $name: $reason');
      continue;
    }
    final json =
        jsonDecode(testFile.readAsStringSync()) as Map<String, Object?>;
    switch (json) {
      case {
          'schema': final String schemaPath,
          'policies': final String policiesPath,
          'should_validate': final bool shouldValidate,
          'entities': final String entitiesPath,
          'queries': final List<Object?> queries,
        }:
        final test = CedarTest(
          name: name,
          schemaJson: jsonDecode(
            File(p.join(testRoot, schemaPath)).readAsStringSync(),
          ) as Map<String, Object?>,
          policiesCedar:
              File(p.join(testRoot, policiesPath)).readAsStringSync(),
          shouldValidate: shouldValidate,
          entitiesJson: jsonDecode(
            File(p.join(testRoot, entitiesPath)).readAsStringSync(),
          ) as List<Object?>,
          queries: queries
              .map(
                (query) => CedarQuery.fromJson(query as Map<String, Object?>),
              )
              .toList(),
        );
        testData[name] = test;
      default:
        throw ArgumentError.value(json, 'json', 'Invalid test data ($name)');
    }
  }
  await outputFile.writeAsString(
    jsonEncode(testData.map((k, v) => MapEntry(k, v.toJson()))),
  );
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
  );
  if (result.exitCode != 0) {
    throw ProcessException(
      'dart',
      ['build_runner', 'build', '--delete-conflicting-outputs'],
      '${result.stdout}\n${result.stderr}',
      result.exitCode,
    );
  }
}
