// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"20f2e031b3c38e109f34bbc7e18de1d7c4f5b5dc","schema_json":{"K":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["K::a"],"resourceTypes":["K::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"@rb_1FF0(\\"\\")\\nforbid(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  (true && (action is K::a)) && (K::a::\\"\\" is K::a)\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"K::a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"K::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
