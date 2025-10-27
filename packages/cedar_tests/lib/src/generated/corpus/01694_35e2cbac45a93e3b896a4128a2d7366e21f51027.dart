// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"35e2cbac45a93e3b896a4128a2d7366e21f51027","schema_json":{"g":{"entityTypes":{"B":{},"Wx":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["g::B"],"resourceTypes":["g::B"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal is g::B in g::B::\\"\\",\\n  action in [g::Action::\\"action\\"],\\n  resource is g::B in g::B::\\"\\"\\n) when {\\n  false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"g::B","id":""},"attrs":{},"parents":[]},{"uid":{"type":"g::Wx","id":"\\u0000"},"attrs":{},"parents":[]},{"uid":{"type":"g::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"g::B","id":""},"resource":{"type":"g::B","id":""},"action":{"type":"g::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
