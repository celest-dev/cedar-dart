// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"649c8c4896ad41a6fe4abb6e078764ac519df743","schema_json":{"":{"entityTypes":{"S":{},"o4":{},"r":{},"w":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["o4","w","r"],"resourceTypes":["o4"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal is o4 in w::\\"\\",\\n  action in [Action::\\"action\\"],\\n  resource is w\\n) when {\\n  true\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"o4","id":""},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"r","id":"\\u0000"},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"w","id":""},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"w","id":""},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"o4","id":""},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"r","id":"\\u0000"},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"r","id":"\\u0000"},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"r","id":"\\u0000"},"resource":{"type":"o4","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
