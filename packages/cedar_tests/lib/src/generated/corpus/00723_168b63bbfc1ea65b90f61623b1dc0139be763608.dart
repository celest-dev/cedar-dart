// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"168b63bbfc1ea65b90f61623b1dc0139be763608","schema_json":{"gCC":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["gCC::a"],"resourceTypes":["gCC::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal is gCC::a,\\n  action in [gCC::Action::\\"action\\",gCC::Action::\\"action\\"],\\n  resource is gCC::a\\n) when {\\n  false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"gCC::a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"gCC::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"gCC::a","id":""},"resource":{"type":"gCC::a","id":""},"action":{"type":"gCC::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
