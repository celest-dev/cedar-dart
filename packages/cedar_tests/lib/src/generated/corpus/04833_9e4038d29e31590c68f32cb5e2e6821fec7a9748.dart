// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"9e4038d29e31590c68f32cb5e2e6821fec7a9748","schema_json":{"":{"entityTypes":{"a":{"tags":{"type":"Boolean"}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is a in a::\\"\\\\u{12}\\",\\n  action in [Action::\\"action\\"],\\n  resource is a\\n) when {\\n  true && ((decimal(\\"77180237.9228\\")) == (datetime(\\"0000-01-01\\")))\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"a","id":"\\u0012"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
