// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"2d9ff9b1fdcdc020a0f4c426bf8b0fc3698cee6b","schema_json":{"":{"entityTypes":{"a":{}},"actions":{":\\u0001":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"@K(\\"\\")\\npermit(\\n  principal,\\n  action,\\n  resource == a::\\"\\\\u{5}\\"\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"a","id":"\\u0005"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":":\\u0001"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"\\u0005"},"resource":{"type":"a","id":"\\u0005"},"action":{"type":"Action","id":":\\u0001"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
