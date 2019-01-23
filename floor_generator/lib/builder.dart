import 'package:build/build.dart';
import 'package:floor_generator/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder floorBuilder(BuilderOptions _) =>
    SharedPartBuilder([FloorGenerator()], 'floor');
