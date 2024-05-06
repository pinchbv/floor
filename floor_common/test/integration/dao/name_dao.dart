import 'package:floor_common/floor_common.dart';

import '../model/mutliline_name.dart';
import '../model/name.dart';

@dao
abstract class NameDao {
  @Query('SELECT * FROM names ORDER BY name ASC')
  Future<List<Name>> findAllNames();

  @Query('SELECT * FROM names ORDER BY name ASC')
  Stream<List<Name>> findAllNamesAsStream();

  @Query('SELECT * FROM names WHERE name = :name')
  Future<Name?> findExactName(String name);

  @Query('SELECT * FROM names WHERE name LIKE :suffix ORDER BY name ASC')
  Future<List<Name>> findNamesLike(String suffix);

  @Query(
      'SELECT * FROM names WHERE name LIKE :suffix AND name LIKE :prefix ORDER BY name ASC')
  Future<List<Name>> findNamesMatchingBoth(String prefix, String suffix);

  @Query('SELECT * FROM multiline_query_names WHERE name = :name')
  Future<MultilineQueryName?> findMultilineQueryName(String name);
}
