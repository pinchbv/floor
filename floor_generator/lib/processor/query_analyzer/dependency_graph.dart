import 'dart:html';

class DependencyGraph {
  final Map<String,Set<String>> _directDependencies={};

  //final Map<String,Set<String>> _indirectDependencyCache={};

  void add(String name,Iterable<String> dependencies){
    _directDependencies.update(
        name,
            (existingDeps) => {...existingDeps, ...dependencies},
        ifAbsent:()=>dependencies
    );
    //_indirectDependencyCache.clear();
  }

//TODO inefficient! is not memoized.

  Set<String> indirectDependencies(String name){
    if (!_directDependencies.containsKey(name)){
      return {name};
    }

    Set<String> output={name};
    Set<String> todo={name};
    while (todo.isNotEmpty){
      final element = todo.first;
      todo.remove(element);
      for(String dependency in _directDependencies[element]){
        if (!output.contains(dependency)){
          output.add(dependency);
          if(_directDependencies.containsKey(dependency)){
            todo.add(dependency);
          }
        }
      }
    }
    return output;
  }



//  Set<String> indirectDependencies(String name){
//    if (_indirectDependencyCache.containsKey(name)){
//      return _indirectDependencyCache[name];
//    }
//
//    if (!_directDependencies.containsKey(name)){
//      _indirectDependencyCache[name]={name};
//      return {name};
//    }
//
//    Set<String> output={name};
//    Set<String> todo={name};
//    while (todo.isNotEmpty){
//      final element = todo.first;
//      todo.remove(element);
//      if(_indirectDependencyCache.containsKey(element)){
//        output.addAll(_indirectDependencyCache[element]);
//        continue;
//      }
//
//      if(_directDependencies.containsKey(element)){
//
//
//
//        output.addAll(_directDependencies[element]);
//      }
//    }
//    _indirectDependencyCache[name]=output;
//    return output;
//  }

//  void _resolveIndirectDependencies(String reference){
//    if (!_indirectDependencyCache.containsKey(reference)) {
//      Set<String> result={reference};
//      if(_directDependencies.containsKey(reference)) {
//        for (String dep in _directDependencies[reference]){
//          // recursively resolve all dependencies
//          _resolveIndirectDependencies(dep);
//          result.addAll(_indirectDependencyCache[dep]);
//        }
//      }
//    }
//  }


}