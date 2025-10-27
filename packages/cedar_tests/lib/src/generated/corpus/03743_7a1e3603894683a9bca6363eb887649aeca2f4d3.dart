// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"7a1e3603894683a9bca6363eb887649aeca2f4d3","schema_json":{"A":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["A::a"],"resourceTypes":["A::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal == A::a::\\"7\\",\\n  action in [A::Action::\\"action\\"],\\n  resource\\n) when {\\n  (true && (\\"\\\\0\\" like \\"\\\\0\\")) && false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"A::a","id":"7"},"attrs":{},"parents":[]},{"uid":{"type":"A::a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"A::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"A::a","id":"7"},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"A::a","id":"7"},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"A::a","id":"7"},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"A::a","id":"7"},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"A::a","id":"7"},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"A::a","id":"7"},"resource":{"type":"A::a","id":"7"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
