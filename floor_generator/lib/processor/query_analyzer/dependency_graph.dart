class DependencyGraph {
  final Map<String, Set<String>> _directDependencies = {};

  final Map<String, Set<String>> _dependencyCache = {};

  void add(String name, Iterable<String> dependencies) {
    _directDependencies.update(
        name, (existingDeps) => {...existingDeps, ...dependencies},
        ifAbsent: () => dependencies.toSet());
    _dependencyCache.clear();
  }

  Set<String> indirectDependencies(String name) {
    if (!_directDependencies.containsKey(name)) {
      return {name};
    }

    if (_dependencyCache.containsKey(name)) {
      return _dependencyCache[name];
    }

    final Set<String> output = {name};
    final Set<String> todo = {name};
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
    _dependencyCache[name] = output;
    return output;
  }
}
