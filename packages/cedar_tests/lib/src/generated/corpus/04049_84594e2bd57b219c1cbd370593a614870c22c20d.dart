// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"84594e2bd57b219c1cbd370593a614870c22c20d","schema_json":{"":{"entityTypes":{"A":{},"r":{}},"actions":{"":{"memberOf":null,"appliesTo":{"principalTypes":["A"],"resourceTypes":["A"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":""},"attrs":{},"parents":[]},{"uid":{"type":"r","id":""},"attrs":{},"parents":[]},{"uid":{"type":"A","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"A","id":""},"resource":{"type":"A","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
