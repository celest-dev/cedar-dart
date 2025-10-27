// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"b732cf7eba7415d76d82f2da204f848f9f883d47","schema_json":{"r":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["r::a"],"resourceTypes":["r::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal,\\n  action,\\n  resource == r::a::\\"h\\"\\n) when {\\n  ((true && (((principal == principal) && false) && false)) && false) && false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"r::a","id":"h"},"attrs":{},"parents":[]},{"uid":{"type":"r::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"r::a","id":"h"},"resource":{"type":"r::a","id":"h"},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
