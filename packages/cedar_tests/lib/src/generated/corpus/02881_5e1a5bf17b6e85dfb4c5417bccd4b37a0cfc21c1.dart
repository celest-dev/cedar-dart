// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"5e1a5bf17b6e85dfb4c5417bccd4b37a0cfc21c1","schema_json":{"":{"entityTypes":{"P":{},"q":{},"r":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["r","P"],"resourceTypes":["r","P"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal == P::\\"\\\\0\\",\\n  action == Action::\\"action\\",\\n  resource in P::\\"\\\\0\\"\\n) when {\\n  (true && (q::\\"\\" in [r::\\"\\", r::\\"\\", resource])) && false\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"P","id":"\\u0000"},"attrs":{},"parents":[]},{"uid":{"type":"q","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"r","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"P","id":"\\u0000"},"resource":{"type":"P","id":"\\u0000"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"P","id":"\\u0000"},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"r","id":""},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"r","id":""},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"r","id":""},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"r","id":""},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"r","id":""},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"r","id":""},"resource":{"type":"r","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
