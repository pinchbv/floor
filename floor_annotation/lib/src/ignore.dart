class Ignore {
  final bool forQuery;
  final bool forInsert;
  final bool forUpdate;
  final bool forDelete;
  const Ignore({this.forQuery = true, this.forInsert = true, this.forUpdate = true, this.forDelete = true});
}

/// Ignores the marked element from Floor's processing logic.
/// It can only be applied to entity's fields.
const ignore = Ignore();
