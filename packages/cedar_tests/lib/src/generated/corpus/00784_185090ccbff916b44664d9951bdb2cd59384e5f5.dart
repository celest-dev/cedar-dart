// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"185090ccbff916b44664d9951bdb2cd59384e5f5","schema_json":{"":{"entityTypes":{"if_":{"shape":{"type":"Record","attributes":{"C":{"type":"String","required":false},"if_":{"type":"String","required":false}}}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["if_"],"resourceTypes":["if_"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"if_","id":""},"attrs":{"if_":"","C":""},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"if_","id":""},"resource":{"type":"if_","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
