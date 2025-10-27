// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"59d1ccae09d012e0c96b0b4748f6bfe20c989580","schema_json":{"":{"entityTypes":{"a":{"tags":{"type":"Boolean"}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal == a::\\"\\\\u{12}\\",\\n  action,\\n  resource == a::\\"\\\\u{12}\\"\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a","id":"\\u0012"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"\\u0012"},"resource":{"type":"a","id":"\\u0012"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
