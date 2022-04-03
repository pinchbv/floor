import 'package:build/build.dart';
import 'package:flat_generator/generator.dart';
import 'package:source_gen/source_gen.dart';

/// This triggers the code generation process.
///
/// Use 'flutter packages pub run build_runner build' to start code generation.
///
/// Use 'flutter packages pub run build_runner watch' to trigger
/// code generation on changes.
Builder flatBuilder(final BuilderOptions _) =>
    SharedPartBuilder([FlatGenerator()], 'flat');
