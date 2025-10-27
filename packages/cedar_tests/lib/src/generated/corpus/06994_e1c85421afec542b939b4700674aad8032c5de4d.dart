// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e1c85421afec542b939b4700674aad8032c5de4d","schema_json":{"A":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["A::a"],"resourceTypes":["A::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is A::a,\\n  action in [A::Action::\\"action\\"],\\n  resource == A::a::\\"\\"\\n) when {\\n  ((true && (_YlHQQ00000000::\\"\\" has \\"\\")) && false) && false\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"A::Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"A::a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
