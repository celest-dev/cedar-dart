// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"b4d211299f2fb083da932df0a45c1265400ca4d2","schema_json":{"":{"entityTypes":{"N":{}},"actions":{"]":{"memberOf":null,"appliesTo":{"principalTypes":["N"],"resourceTypes":["N"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal in N::\\"\\",\\n  action,\\n  resource\\n) when {\\n  (true && ((duration(\\"-1099494981530d\\")) == (duration(\\"0ms\\")))) && false\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"Action","id":"]"},"attrs":{},"parents":[]},{"uid":{"type":"N","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 1","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 2","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 3","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 4","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 5","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 6","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 7","principal":{"type":"N","id":""},"resource":{"type":"N","id":""},"action":{"type":"Action","id":"]"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
