class Fts3 {
  /// The tokenizer to be used in the FTS table.
  /// <p>
  /// The default value is [FtsTokenizer.simple]. Tokenizer arguments can be defined
  /// with [tokenizerArgs].
  /// <p>
  /// If a custom tokenizer is used, the tokenizer and its arguments are not verified at compile
  /// time.
  ///
  /// @return The tokenizer to use on the FTS table. Built-in available tokenizers are
  /// [FtsTokenizer.simple],[FtsTokenizer.porter] and
  /// [FtsTokenizer.unicode61].
  /// [tokenizerArgs]
  /// [SQLite tokernizers documentation](https://www.sqlite.org/fts3.html#tokenizer)
  final String tokenizer;

  /// Optional arguments to configure the defined tokenizer.
  /// <p>
  /// Tokenizer arguments consist of an argument name, followed by an "=" character, followed by
  /// the option value. For example, <code>separators=.</code> defines the dot character as an
  /// additional separator when using the [FtsTokenizer.unicode61] tokenizer.
  /// <p>
  /// The available arguments that can be defined depend on the tokenizer defined, see the
  /// [SQLite tokernizers documentation](https://www.sqlite.org/fts3.html#tokenizer) for
  /// details.
  ///
  /// @return A list of tokenizer arguments strings.
  final List<String> tokenizerArgs;

  const Fts3({
    this.tokenizer = FtsTokenizer.simple,
    this.tokenizerArgs = const [],
  });
}

const fts3 = Fts3();

class Fts4 {
  /// The tokenizer to be used in the FTS table.
  /// <p>
  /// The default value is [FtsTokenizer.simple]. Tokenizer arguments can be defined
  /// with [tokenizer].
  /// <p>
  /// If a custom tokenizer is used, the tokenizer and its arguments are not verified at compile
  /// time.
  ///
  /// @return The tokenizer to use on the FTS table. Built-in available tokenizers are
  /// [FtsTokenizer.simple], [FtsTokenizer.porter] and
  /// [FtsTokenizer.unicode61].
  /// [tokenizerArgs]
  /// [SQLite tokernizers documentation](https://www.sqlite.org/fts3.html#tokenizer)
  final String tokenizer;

  /// Optional arguments to configure the defined tokenizer.
  /// <p>
  /// Tokenizer arguments consist of an argument name, followed by an "=" character, followed by
  /// the option value. For example, <code>separators=.</code> defines the dot character as an
  /// additional separator when using the {@link FtsOptions#TOKENIZER_UNICODE61} tokenizer.
  /// <p>
  /// The available arguments that can be defined depend on the tokenizer defined, see the
  /// [SQLite tokernizers documentation](https://www.sqlite.org/fts3.html#tokenizer) for
  /// details.
  ///
  /// @return A list of tokenizer arguments strings.
  final List<String> tokenizerArgs;

  const Fts4({
    this.tokenizer = FtsTokenizer.simple,
    this.tokenizerArgs = const [],
  });
}

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
  /// <p>
  /// Not available in certain Android builds (e.g. vendor).
  ///
  /// [Fts4.tokenizer]
  static const icu = 'icu';

  /// The name of the tokenizer that extends the {@link #TOKENIZER_SIMPLE} tokenizer
  /// according to rules in Unicode Version 6.1.
  ///
  /// [Fts3.tokenizer]
  /// [Fts4.tokenizer]
  /// required Android API > 21
  static const unicode61 = 'unicode61';
}
