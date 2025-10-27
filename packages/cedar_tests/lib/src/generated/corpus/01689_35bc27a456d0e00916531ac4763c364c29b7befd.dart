// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"35bc27a456d0e00916531ac4763c364c29b7befd","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal == a::\\"\\\\u{1}Έ\\",\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a","id":"\\u0001Έ"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"\\u0001Έ"},"resource":{"type":"a","id":"\\u0001Έ"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
