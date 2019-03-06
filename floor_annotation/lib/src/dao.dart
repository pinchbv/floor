class _Dao {
  const _Dao();
}

/// Marks the class as a Data Access Object.
///
/// Data Access Objects are the main classes where you define your database
/// interactions. They can include a variety of query methods.
/// The class marked with @dao should either be an abstract class. At compile
/// time, Floor will generate an implementation of this class when it is
/// referenced by a Database.
///
/// It is recommended to have multiple Dao classes in your codebase depending
/// on the tables they touch.
const dao = _Dao();
