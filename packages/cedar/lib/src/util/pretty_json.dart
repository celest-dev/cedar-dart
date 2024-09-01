import 'dart:convert';

String prettyJson(Object? o) => const JsonEncoder.withIndent('  ').convert(o);
