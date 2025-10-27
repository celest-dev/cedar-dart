// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"d2264ed900d8c85835fb230907b2a5022cee9f38","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  (true && (!(9033657953222153010 < (-3255259059144852020)))) && false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
