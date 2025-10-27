// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"f520fb331133dd7ed74a9bbf7138390ad2212324","schema_json":{"":{"entityTypes":{"C":{},"r":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["C"],"resourceTypes":["C"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"C","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"r","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"C","id":""},"resource":{"type":"C","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
