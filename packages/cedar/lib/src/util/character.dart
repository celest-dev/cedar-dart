/// An ASCII character.
extension type const Character(int char) implements int {
  static const Character nullChar = Character(0x00); // '\0'
  static const Character space = Character(0x20); // ' '
  static const Character tab = Character(0x09); // '\t'
  static const Character doubleQuote = Character(0x22); // '"'
  static const Character questionMark = Character(0x3F); // '?'
  static const Character star = Character(0x2A); // '*'
  static const Character colon = Character(0x3A); // ':'
  static const Character zero = Character(0x30); // '0'
  static const Character one = Character(0x31); // '1'
  static const Character nine = Character(0x39); // '9'
  static const Character upperA = Character(0x41); // 'A'
  static const Character upperZ = Character(0x5A); // 'Z'
  static const Character lowerA = Character(0x61); // 'a'
  static const Character lowerZ = Character(0x7A); // 'z'
  static const Character exclamationMark = Character(0x21); // '!'
  static const Character numberSign = Character(0x23); // '#'
  static const Character dollarSign = Character(0x24); // '$'
  static const Character percent = Character(0x25); // '%'
  static const Character and = Character(0x26); // '&'
  static const Character singleQuote = Character(0x27); // '\''
  static const Character plus = Character(0x2B); // '+'
  static const Character minus = Character(0x2D); // '-'
  static const Character dash = minus; // '-'
  static const Character decimal = Character(0x2E); // '.'
  static const Character caret = Character(0x5E); // '^'
  static const Character underscore = Character(0x5F); // '_'
  static const Character backtick = Character(0x60); // '`'
  static const Character pipe = Character(0x7C); // '|'
  static const Character tilde = Character(0x7E); // '~'
  static const Character slash = Character(0x2F); // '/'
  static const Character backslash = Character(0x5C); // '\'
  static const Character semiColon = Character(0x3B); // ';'
  static const Character equals = Character(0x3D); // '='
  static const Character comma = Character(0x2C); // ','
  static const Character openParen = Character(0x28); // '('
  static const Character closeParen = Character(0x29); // ')'
  static const Character at = Character(0x40); // '@'
  static const Character lineFeed = Character(0x0A); // '\n'
  static const Character carriageReturn = Character(0x0D); // '\r'
  static const Character leftCurlyBrace = Character(0x7B); // '{'
  static const Character rightCurlyBrace = Character(0x7D); // '}'
  static const Character maxAscii = Character(0x7F); // '\x7F'

  static const Character lowerAlphaA = Character(0x61); // 'a'
  static const Character lowerAlphaB = Character(0x62); // 'b'
  static const Character lowerAlphaC = Character(0x63); // 'c'
  static const Character lowerAlphaD = Character(0x64); // 'd'
  static const Character lowerAlphaE = Character(0x65); // 'e'
  static const Character lowerAlphaF = Character(0x66); // 'f'
  static const Character lowerAlphaG = Character(0x67); // 'g'
  static const Character lowerAlphaH = Character(0x68); // 'h'
  static const Character lowerAlphaI = Character(0x69); // 'i'
  static const Character lowerAlphaJ = Character(0x6A); // 'j'
  static const Character lowerAlphaK = Character(0x6B); // 'k'
  static const Character lowerAlphaL = Character(0x6C); // 'l'
  static const Character lowerAlphaM = Character(0x6D); // 'm'
  static const Character lowerAlphaN = Character(0x6E); // 'n'
  static const Character lowerAlphaO = Character(0x6F); // 'o'
  static const Character lowerAlphaP = Character(0x70); // 'p'
  static const Character lowerAlphaQ = Character(0x71); // 'q'
  static const Character lowerAlphaR = Character(0x72); // 'r'
  static const Character lowerAlphaS = Character(0x73); // 's'
  static const Character lowerAlphaT = Character(0x74); // 't'
  static const Character lowerAlphaU = Character(0x75); // 'u'
  static const Character lowerAlphaV = Character(0x76); // 'v'
  static const Character lowerAlphaW = Character(0x77); // 'w'
  static const Character lowerAlphaX = Character(0x78); // 'x'
  static const Character lowerAlphaY = Character(0x79); // 'y'
  static const Character lowerAlphaZ = Character(0x7A); // 'z'

  static const Character upperAlphaA = Character(0x41); // 'A'
  static const Character upperAlphaB = Character(0x42); // 'B'
  static const Character upperAlphaC = Character(0x43); // 'C'
  static const Character upperAlphaD = Character(0x44); // 'D'
  static const Character upperAlphaE = Character(0x45); // 'E'
  static const Character upperAlphaF = Character(0x46); // 'F'

  /// Characters below [self] are represented as themselves in a single byte.
  static const Character self = Character(0x80);

  // Code points in the surrogate range are not valid for UTF-8.
  static const Character surrogateMin = Character(0xD800);
  static const Character surrogateMax = Character(0xDFFF);

  /// Maximum valid Unicode code point.
  static const Character maxValid = Character(0x10FFFF);

  /// An alpha character, e.g. A-Z or a-z.
  bool get isAlpha =>
      this >= upperA && this <= upperZ || this >= lowerA && this <= lowerZ;

  /// A lowercase alpha character, e.g. a-z.
  bool get isLowerAlpha => this >= lowerA && this <= lowerZ;

  /// A digit character, e.g. 0-9.
  bool get isDigit => this >= zero && this <= nine;

  /// The digit value of this character, e.g. 0-15.
  int get digitValue {
    if (isDigit) {
      return this - zero;
    }
    if (this >= upperAlphaA && this <= upperAlphaF) {
      return this - upperAlphaA + 10;
    }
    if (this >= lowerAlphaA && this <= lowerAlphaF) {
      return this - lowerAlphaA + 10;
    }
    throw ArgumentError.value(this, 'ch', 'not a valid digit');
  }

  /// A valid hex character, e.g. 0-9, A-F, or a-f.
  bool get isValidHex =>
      isDigit ||
      this >= upperAlphaA && this <= upperAlphaF ||
      this >= lowerAlphaA && this <= lowerAlphaF;

  /// Whether this can be legally encoded as UTF-8.
  ///
  /// Code points that are out of range or a surrogate half are illegal.
  bool get isValueUtf8Rune {
    if (this >= 0 && this < surrogateMin) {
      return true;
    }
    if (this > surrogateMax && this <= maxValid) {
      return true;
    }
    return false;
  }

  /// A whitespace character, e.g. ' ', '\n', '\r' or '\t'.
  bool get isWhitespace =>
      this == space ||
      this == tab ||
      this == lineFeed ||
      this == carriageReturn;

  /// Whether this is a valid [Token] character.
  bool get isExtendedTokenCharacter {
    if (isAlpha || isDigit) {
      return true;
    }
    return this == exclamationMark ||
        this == numberSign ||
        this == dollarSign ||
        this == percent ||
        this == and ||
        this == singleQuote ||
        this == star ||
        this == plus ||
        this == minus ||
        this == decimal ||
        this == caret ||
        this == underscore ||
        this == backtick ||
        this == pipe ||
        this == tilde ||
        this == colon ||
        this == slash;
  }

  /// Whether this is a valid [Key] character.
  bool get isKeyCharacter {
    if (isLowerAlpha || isDigit) {
      return true;
    }
    return this == underscore ||
        this == minus ||
        this == decimal ||
        this == star;
  }

  /// A visible ASCII character (VCHAR), e.g. 0x21 (!) to 0x7E (~).
  ///
  /// See: https://www.rfc-editor.org/rfc/rfc5234#appendix-B.1
  bool get isVisibleAscii => this >= exclamationMark && this < maxAscii;

  /// An ASCII character which is not a VCHAR or SP.
  bool get isInvalidAscii => !isVisibleAscii && this != space;

  /// Whether this is a valid base64 character.
  bool get isValidBase64 =>
      isAlpha || isDigit || this == plus || this == slash || this == equals;
}
