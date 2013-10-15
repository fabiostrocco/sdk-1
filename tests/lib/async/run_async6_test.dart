// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library run_async_test;

import 'dart:async';
import '../../../pkg/unittest/lib/unittest.dart';

bool _unhandledExceptionCallback(exception) => true;

main() {
  test('run async test', () {
    var callback = expectAsync0(() {});
    runAsync(() {
      runAsync(() {
        callback();
      });
      throw new Exception('exception');
    });
  });
}