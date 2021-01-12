abstract class Fts {
  String get usingOption;

  String tableCreateOption();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fts &&
          runtimeType == other.runtimeType &&
          usingOption == other.usingOption &&
          tableCreateOption() == other.tableCreateOption();

  @override
  int get hashCode => usingOption.hashCode ^ tableCreateOption.hashCode;

  @override
  String toString() {
    return 'Fts{type: $usingOption, tokenizer: ${tableCreateOption()}}';
  }
}

class Fts3 extends Fts {
  final String tokenizer;
  final List<String> tokenizerArgs;

  Fts3(
    this.tokenizer,
    this.tokenizerArgs,
  );

  @override
  String get usingOption => 'USING fts3';

  @override
  String tableCreateOption() {
    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write('tokenize=$tokenizer ');
    if (tokenizerArgs != null && tokenizerArgs.isNotEmpty) {
      stringBuffer.write(tokenizerArgs.join(' '));
    }

    return stringBuffer.toString();
  }
}

class Fts4 extends Fts {
  final String tokenizer;
  final List<String> tokenizerArgs;

  Fts4(
    this.tokenizer,
    this.tokenizerArgs,
  );

  @override
  String get usingOption => 'USING fts4';

  @override
  String tableCreateOption() {
    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write('tokenize=$tokenizer ');
    if (tokenizerArgs != null && tokenizerArgs.isNotEmpty) {
      stringBuffer.write(tokenizerArgs.join(' '));
    }
    return stringBuffer.toString();
  }
}
