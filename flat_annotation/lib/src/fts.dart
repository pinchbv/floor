/// Marks an Entity annotated class as an FTS3 entity.
/// This class will have a mapping SQLite FTS3 table in the database.
class Fts3 {
  /// The tokenizer to be used in the FTS table.
  /// The default value is [FtsTokenizer.simple]. Tokenizer arguments can be defined
  /// with [tokenizerArgs].
  ///
  /// The tokenizer to use on the FTS table. Built-in available tokenizers are
  /// [FtsTokenizer.simple],[FtsTokenizer.porter] and [FtsTokenizer.unicode61].
  ///
  /// [SQLite tokenizers documentation](https://www.sqlite.org/fts3.html#tokenizer)
  final String tokenizer;

  /// Optional arguments to configure the defined tokenizer.
  ///
  /// Tokenizer arguments consist of an argument name, followed by an "=" character, followed by
  /// the option value. For example, `separators=.` defines the dot character as an
  /// additional separator when using the [FtsTokenizer.unicode61] tokenizer.
  ///
  /// The available arguments that can be defined depend on the tokenizer defined, see the
  /// [SQLite tokenizers documentation](https://www.sqlite.org/fts3.html#tokenizer) for
  /// details.
  ///
  /// A list of tokenizer arguments strings.
  final List<String> tokenizerArgs;

  /// Creates an [Fts3] constant which can be used to mark an Entity annotated
  /// class as an FTS3 entity.
  const Fts3({
    this.tokenizer = FtsTokenizer.simple,
    this.tokenizerArgs = const [],
  });
}

/// Marks an Entity annotated class as an FTS3 entity.
/// This class will have a mapping SQLite FTS3 table in the database.
///
/// It uses the [FtsTokenizer.simple] with no additional [Fts3.tokenizerArgs].
const fts3 = Fts3();

/// Marks an Entity annotated class as an FTS4 entity.
/// This class will have a mapping SQLite FTS4 table in the database.
class Fts4 {
  /// The tokenizer to be used in the FTS table.
  /// The default value is [FtsTokenizer.simple]. Tokenizer arguments can be defined
  /// with [tokenizerArgs].
  ///
  /// The tokenizer to use on the FTS table. Built-in available tokenizers are
  /// [FtsTokenizer.simple],[FtsTokenizer.porter] and [FtsTokenizer.unicode61].
  ///
  /// [SQLite tokenizers documentation](https://www.sqlite.org/fts3.html#tokenizer)
  final String tokenizer;

  /// Optional arguments to configure the defined tokenizer.
  ///
  /// Tokenizer arguments consist of an argument name, followed by an "=" character, followed by
  /// the option value. For example, `separators=.` defines the dot character as an
  /// additional separator when using the [FtsTokenizer.unicode61] tokenizer.
  ///
  /// The available arguments that can be defined depend on the tokenizer defined, see the
  /// [SQLite tokenizers documentation](https://www.sqlite.org/fts3.html#tokenizer) for
  /// details.
  ///
  /// A list of tokenizer arguments strings.
  final List<String> tokenizerArgs;

  /// Creates an [Fts4] constant which can be used to mark an Entity annotated
  /// class as an FTS4 entity.
  const Fts4({
    this.tokenizer = FtsTokenizer.simple,
    this.tokenizerArgs = const [],
  });
}

/// Marks an Entity annotated class as an FTS4 entity.
/// This class will have a mapping SQLite FTS4 table in the database.
///
/// It uses the [FtsTokenizer.simple] with no additional [Fts4.tokenizerArgs].
const fts4 = Fts4();

/// Available option values that can be used with [Fts3] & [Fts4].
abstract class FtsTokenizer {
  /// The name of the default tokenizer used on FTS tables.
  ///
  /// [Fts3.tokenizer]
  /// [Fts4.tokenizer]
  static const simple = 'simple';

  /// The name of the tokenizer based on the Porter Stemming Algorithm.
  ///
  /// [Fts3.tokenizer]
  /// [Fts4.tokenizer]
  static const porter = 'porter';

  /// The name of a tokenizer implemented by the ICU library.
  /// Not available in certain Android builds (e.g. vendor).
  ///
  /// [Fts3.tokenizer]
  /// [Fts4.tokenizer]
  static const icu = 'icu';

  /// The name of the tokenizer that extends the [simple] tokenizer
  /// according to rules in Unicode Version 6.1.
  ///
  /// [Fts3.tokenizer]
  /// [Fts4.tokenizer]
  static const unicode61 = 'unicode61';
}
