// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"184b0fecea901e97ed77d168ed7ecf58c241bb3d","schema_json":{"":{"entityTypes":{"dqq8":{},"dqqqqqqqq":{}},"actions":{"":{"memberOf":null,"appliesTo":{"principalTypes":["dqq8"],"resourceTypes":["dqq8"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"dqqqqqqqq","id":""},"attrs":{},"parents":[]},{"uid":{"type":"dqq8","id":""},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"dqq8","id":""},"resource":{"type":"dqq8","id":""},"action":{"type":"Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
