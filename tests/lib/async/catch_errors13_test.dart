// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'dart:async';
import 'dart:isolate';
import 'catch_errors.dart';

main() {
  // We keep a ReceivePort open until all tests are done. This way the VM will
  // hang if the callbacks are not invoked and the test will time out.
  var port = new ReceivePort();
  var events = [];
  // Work around bug that makes runAsync use Timers. By invoking `runAsync` here
  // we make sure that asynchronous non-timer events are executed before any
  // Timer events.
  runAsync(() { });

  // Test that errors are caught by nested `catchErrors`. Also uses `runAsync`
  // in the body of a Timer.
  catchErrors(() {
    events.add("catch error entry");
    catchErrors(() {
      events.add("catch error entry2");
      Timer.run(() { throw "timer error"; });
      new Timer(const Duration(milliseconds: 50),
                () {
                     runAsync(() { throw "runAsync"; });
                     throw "delayed error";
                   });
    }).listen((x) { events.add(x); })
      .asFuture()
      .then((_) => events.add("inner done"))
      .then((_) { throw "inner done throw"; });
    events.add("after inner");
    Timer.run(() { throw "timer outer"; });
    throw "inner throw";
  }).listen((x) {
      events.add(x);
    },
    onDone: () {
      Expect.listEquals([
                         "catch error entry",
                         "catch error entry2",
                         "after inner",
                         "main exit",
                         "inner throw",
                         "timer error",
                         "timer outer",
                         "delayed error",
                         "runAsync",
                         "inner done",
                         "inner done throw"
                         ],
                         events);
      port.close();
    });
  events.add("main exit");
}