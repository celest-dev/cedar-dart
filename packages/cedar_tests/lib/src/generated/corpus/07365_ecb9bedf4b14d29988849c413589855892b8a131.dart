// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"ecb9bedf4b14d29988849c413589855892b8a131","schema_json":{"":{"entityTypes":{"A":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["A"],"resourceTypes":["A"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"@Fpprpg00(\\"\\")\\nforbid(\\n  principal in A::\\"\\",\\n  action in [Action::\\"action\\"],\\n  resource in A::\\"\\"\\n) when {\\n  true && (resource in (if (principal in []) then (if true then [] else []) else (if true then [] else [])))\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"A","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
