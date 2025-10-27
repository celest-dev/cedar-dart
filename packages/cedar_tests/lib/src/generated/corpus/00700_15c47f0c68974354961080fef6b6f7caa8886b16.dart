// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"15c47f0c68974354961080fef6b6f7caa8886b16","schema_json":{"a":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a::a"],"resourceTypes":["a::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal in a::a::\\"\\",\\n  action == a::Action::\\"action\\",\\n  resource == a::a::\\"\\"\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a::a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"a::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a::a","id":""},"resource":{"type":"a::a","id":""},"action":{"type":"a::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
