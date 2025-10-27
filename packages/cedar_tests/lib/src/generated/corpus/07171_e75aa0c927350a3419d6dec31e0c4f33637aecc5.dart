// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e75aa0c927350a3419d6dec31e0c4f33637aecc5","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  (true && ((((decimal(\\"9Ì2337203685477.5807\\")) == (decimal(\\"922337203685477.5807\\"))) || false) || false)) && false\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"Action","id":""},"attrs":{},"parents":[]},{"uid":{"type":"a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 3","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 4","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 5","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 6","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 7","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
