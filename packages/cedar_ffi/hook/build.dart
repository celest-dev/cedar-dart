import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_rs/native_toolchain_rs.dart';

IOSink _buildLogs(Uri packageRoot) {
  final logsFile = File.fromUri(packageRoot.resolve('./.dart_tool/build.log'));
  logsFile.createSync(recursive: true);
  return logsFile.openWrite(mode: FileMode.write)
    ..writeln('Starting build: ${DateTime.now()}');
}

void main(List<String> args) async {
  late final IOSink buildLogs;
  try {
    await build(args, (input, output) async {
      buildLogs = _buildLogs(input.packageRoot);
      final logger = Logger('cedar_ffi_build')
        ..onRecord.listen((record) {
          buildLogs.writeln(
            '[${record.level.name}] ${record.time.toIso8601String()} ${record.message}',
          );
          if (record.error != null) {
            buildLogs.writeln('error: ${record.error}');
          }
          if (record.stackTrace != null) {
            buildLogs.writeln(record.stackTrace.toString());
          }
        });

      buildLogs.writeln(input.json);

      final srcDir = Directory.fromUri(input.packageRoot.resolve('./src/src'));
      if (!srcDir.existsSync()) {
        throw StateError('Expected src/ directory at ${srcDir.path}');
      }

      final dependencies = srcDir
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.uri);
      buildLogs.writeln('Dependencies:');
      for (final dep in dependencies) {
        buildLogs.writeln(' - $dep');
      }

      output.dependencies.addAll(dependencies);
      await const RustBuilder(
        assetName: 'src/ffi/cedar_bindings.ffi.dart',
        cratePath: 'src',
      ).run(input: input, output: output, logger: logger);
    });
  } finally {
    await buildLogs.flush();
    await buildLogs.close();
  }
}
