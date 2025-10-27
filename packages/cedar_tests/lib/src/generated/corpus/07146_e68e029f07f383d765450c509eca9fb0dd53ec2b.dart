// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e68e029f07f383d765450c509eca9fb0dd53ec2b","schema_json":{"":{"entityTypes":{"y":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["y"],"resourceTypes":["y"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"y","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"y","id":""},"resource":{"type":"y","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
