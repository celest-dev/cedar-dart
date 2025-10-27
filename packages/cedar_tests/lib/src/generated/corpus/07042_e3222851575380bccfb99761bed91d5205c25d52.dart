// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e3222851575380bccfb99761bed91d5205c25d52","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"OOOOO":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is a,\\n  action in [Action::\\"OOOOO\\",Action::\\"OOOOO\\"],\\n  resource is a\\n) when {\\n  (true && (!((-(-((-9223372036854775808)))) < (-(-((-9223372036854775808))))))) && false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"OOOOO"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 1","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 2","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 3","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 4","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 5","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 6","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 7","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":"OOOOO"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
