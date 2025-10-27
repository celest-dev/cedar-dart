// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"ee8638fac71e3f6fcfe4beb1f62df0363df62d05","schema_json":{"":{"entityTypes":{"b":{},"c":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["c"],"resourceTypes":["c"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is b,\\n  action in [Action::\\"action\\"],\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"b","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"c","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
