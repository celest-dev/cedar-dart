// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"b9b6a3817b460c302531bb470e767fa2a0ba8532","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is a,\\n  action,\\n  resource is a in a::\\"XX.P\\"\\n) when {\\n  ((true && (a::\\"XX.P\\" in a::\\"XX.P\\")) && (!((-((-44946) * 1026498302207)) <= 0))) && false\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":"XX.P"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"XX.P"},"resource":{"type":"a","id":"XX.P"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
