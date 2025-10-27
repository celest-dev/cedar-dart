// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"93bd1bb12d470dbe12c629bdf784e63fed404407","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is a in a::\\"\\\\0\\",\\n  action in [Action::\\"\\",Action::\\"\\"],\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"\\u0000"},"resource":{"type":"a","id":"\\u0000"},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"\\u0000"},"resource":{"type":"a","id":"\\u0000"},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"\\u0000"},"resource":{"type":"a","id":"\\u0000"},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"\\u0000"},"resource":{"type":"a","id":"\\u0000"},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"\\u0000"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"\\u0000"},"resource":{"type":"a","id":"\\u0000"},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
