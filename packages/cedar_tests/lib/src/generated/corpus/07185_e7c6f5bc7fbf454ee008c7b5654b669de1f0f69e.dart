// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e7c6f5bc7fbf454ee008c7b5654b669de1f0f69e","schema_json":{"":{"entityTypes":{"a":{"tags":{"type":"String"}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is a in a::\\"-\\",\\n  action in [Action::\\"action\\"],\\n  resource == a::\\"-\\"\\n) when {\\n  (true && (a::\\"-\\" in a::\\"-\\")) && (!(!(4051323452948762066 == (datetime(\\"3970-07-25T14:39:09\\")))))\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":"-"},"attrs":{},"parents":[],"tags":{"":""}}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"-"},"resource":{"type":"a","id":"-"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":"\\u0000"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"-"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"-"},"resource":{"type":"a","id":"-"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 5","principal":{"type":"a","id":"-"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"ioooooooo"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
