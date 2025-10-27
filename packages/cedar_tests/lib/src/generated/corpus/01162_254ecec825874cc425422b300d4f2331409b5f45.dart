// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"254ecec825874cc425422b300d4f2331409b5f45","schema_json":{"":{"entityTypes":{"_":{"tags":{"type":"String"}},"c":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["_","c"],"resourceTypes":["c","_"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal == _::\\"\\",\\n  action in [Action::\\"action\\"],\\n  resource == c::\\"\\"\\n) when {\\n  false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"_","id":""},"attrs":{},"parents":[],"tags":{"":""}},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"c","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"_","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"c","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"_","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"_","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"_","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"_","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"_","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"_","id":""},"resource":{"type":"c","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
