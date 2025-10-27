// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"790e4c52c99defc2c670d3d9867758a98a9c122a","schema_json":{"":{"entityTypes":{"a":{"tags":{"type":"String"}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"@ReNbcagqg(\\"\\")\\n@a(\\"\\")\\n@r(\\"\\")\\nforbid(\\n  principal == a::\\"\\",\\n  action in [Action::\\"action\\"],\\n  resource in a::\\"^\\"\\n) when {\\n  (true && (((ip(\\"\\")).isMulticast()) || (!(9223372036854775807 <= 9223372036854775807)))) && (resource in resource)\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"a","id":"^"},"attrs":{},"parents":[],"tags":{"":""}},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"^"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":"^"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"^"},"resource":{"type":"a","id":"^"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"^"},"resource":{"type":"a","id":"^"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"^"},"resource":{"type":"a","id":"^"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"^"},"resource":{"type":"a","id":"^"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
