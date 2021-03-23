// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//Copied from https://github.com/dart-lang/json_serializable/blob/master/json_serializable/test/test_file_utils.dart

import 'dart:mirrors';

import 'package:path/path.dart' as p;

String testFilePath(String part1, [String? part2, String? part3]) =>
    p.join(_packagePath(), part1, part2, part3);

String? _packagePathCache;

String _packagePath() {
  if (_packagePathCache == null) {
    // Getting the location of this file – via reflection
    final currentFilePath = (reflect(_packagePath) as ClosureMirror)
        .function
        .location!
        .sourceUri
        .path;

    _packagePathCache = p.normalize(p.join(p.dirname(currentFilePath), '..'));
    _packagePathCache = _packagePathCache!.substring(1);
  }
  return _packagePathCache!;
}