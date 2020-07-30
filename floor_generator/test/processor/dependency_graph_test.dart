import 'package:floor_generator/misc/string_utils.dart';
import 'package:floor_generator/processor/query_analyzer/dependency_graph.dart';
import 'package:test/test.dart';

void main() {
  DependencyGraph graph;

  setUp(() {
    graph = DependencyGraph();
  });

  test('empty graph', () {
    expect(graph.indirectDependencies('foo'), {'foo'});
    expect(graph.indirectDependencies(null), {null});
  });

  test('single dependency', () {
    graph.add('foo', ['bar', 'baz']);

    expect(graph.indirectDependencies('foo'), {'foo', 'bar', 'baz'});
    expect(graph.indirectDependencies(null), {null});
    expect(graph.indirectDependencies('bar'), {'bar'});
    expect(graph.indirectDependencies('baz'), {'baz'});
  });

  test('transitive dependency', () {
    graph.add('foo', ['bar']);
    graph.add('bar', ['baz']);

    expect(graph.indirectDependencies(null), {null});
    expect(graph.indirectDependencies('foo'), {'foo', 'bar', 'baz'});
    expect(graph.indirectDependencies('bar'), {'bar', 'baz'});
    expect(graph.indirectDependencies('baz'), {'baz'});
  });

  test('transitive dependency with cycle', () {
    graph.add('foo', ['bar', 'baz']);
    graph.add('bar', ['baz']);
    graph.add('baz', ['far']);
    graph.add('far', ['bar']);

    expect(graph.indirectDependencies(null), {null});
    expect(graph.indirectDependencies('other'), {'other'});
    expect(graph.indirectDependencies('foo'), {'foo', 'bar', 'baz', 'far'});
    expect(graph.indirectDependencies('bar'), {'bar', 'baz', 'far'});
    expect(graph.indirectDependencies('far'), {'bar', 'baz', 'far'});
    expect(graph.indirectDependencies('baz'), {'bar', 'baz', 'far'});
  });
}
