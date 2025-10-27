// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"b8a9caf5133f19409a8b2b749469c5fcd30b8823","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"bir":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal == a::\\"+쬬+\\",\\n  action == Action::\\"bir\\",\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a","id":"+쬬+"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"bir"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"+쬬+"},"resource":{"type":"a","id":"+쬬+"},"action":{"type":"Action","id":"bir"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
