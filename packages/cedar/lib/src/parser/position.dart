import 'package:cedar/src/proto/cedar/v3/policy.pb.dart' as pb;

final class Position {
  const Position({
    this.filename,
    required this.offset,
    required this.line,
    required this.column,
  });

  const Position.unknown()
      : this(
          offset: 0,
          line: 0,
          column: 0,
        );

  factory Position.fromJson(Map<String, Object?> json) {
    return Position(
      filename: switch (json['filename']) {
        final String filename => Uri.parse(filename),
        _ => null,
      },
      offset: json['offset'] as int,
      line: json['line'] as int,
      column: json['column'] as int,
    );
  }

  factory Position.fromProto(pb.Position position) {
    return Position(
      filename: position.hasFilename() ? Uri.parse(position.filename) : null,
      offset: position.offset,
      line: position.line,
      column: position.column,
    );
  }

  final Uri? filename;
  final int offset;
  final int line;
  final int column;

  Map<String, Object?> toJson() => {
        if (filename case final filename?) 'filename': filename.toString(),
        'offset': offset,
        'line': line,
        'column': column,
      };

  pb.Position toProto() => pb.Position(
        filename: filename?.toString(),
        offset: offset,
        line: line,
        column: column,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          filename == other.filename &&
          offset == other.offset &&
          line == other.line &&
          column == other.column;

  @override
  int get hashCode => Object.hash(filename, offset, line, column);
}
