// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"2f417e89fbf57b0316b071d2828a022cf93082d3","schema_json":{"":{"entityTypes":{"S":{},"o4":{},"r":{},"w":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["w"],"resourceTypes":["w"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal,\\n  action,\\n  resource is r\\n) when {\\n  true\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"o4","id":""},"attrs":{},"parents":[]},{"uid":{"type":"r","id":"\\u000e"},"attrs":{},"parents":[]},{"uid":{"type":"w","id":""},"attrs":{},"parents":[]},{"uid":{"type":"r","id":""},"attrs":{},"parents":[]},{"uid":{"type":"S","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"w","id":""},"resource":{"type":"w","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
