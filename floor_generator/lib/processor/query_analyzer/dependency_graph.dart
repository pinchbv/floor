//maybe inefficient! is not memoized.
class DependencyGraph {
  final Map<String, Set<String>> _directDependencies = {};

  void add(String name, Iterable<String> dependencies) {
    _directDependencies.update(
        name, (existingDeps) => {...existingDeps, ...dependencies},
        ifAbsent: () => dependencies.toSet());
  }

  Set<String> indirectDependencies(String name) {
    if (!_directDependencies.containsKey(name)) {
      return {name};
    }

    Set<String> output = {name};
    Set<String> todo = {name};
    while (todo.isNotEmpty) {
      final element = todo.first;
      todo.remove(element);
      for (String dependency in _directDependencies[element]) {
        if (!output.contains(dependency)) {
          output.add(dependency);
          if (_directDependencies.containsKey(dependency)) {
            todo.add(dependency);
          }
        }
      }
    }
    return output;
  }
}
