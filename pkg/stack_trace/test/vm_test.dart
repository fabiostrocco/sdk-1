// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This file tests stack_trace's ability to parse live stack traces. It's a
/// dual of dartium_test.dart, since method names can differ somewhat from
/// platform to platform. No similar file exists for dart2js since the specific
/// method names there are implementation details.

import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart';
import 'package:unittest/unittest.dart';

String getStackTraceString() {
  try {
    throw '';
  } catch (_, stackTrace) {
    return stackTrace.toString();
  }
}

StackTrace getStackTraceObject() {
  try {
    throw '';
  } catch (_, stackTrace) {
    return stackTrace;
  }
}

Frame getCaller([int level]) {
  if (level == null) return new Frame.caller();
  return new Frame.caller(level);
}

Frame nestedGetCaller(int level) => getCaller(level);

Trace getCurrentTrace([int level]) => new Trace.current(level);

Trace nestedGetCurrentTrace(int level) => getCurrentTrace(level);

void main() {
  group('Trace', () {
    test('.parse parses a real stack trace correctly', () {
      var string = getStackTraceString();
      var trace = new Trace.parse(string);
      var builder = new path.Builder(style: path.Style.url);
      expect(builder.basename(trace.frames.first.uri.path),
          equals('vm_test.dart'));
      expect(trace.frames.first.member, equals('getStackTraceString'));
    });

    test('converts from a native stack trace correctly', () {
      var trace = new Trace.from(getStackTraceObject());
      var builder = new path.Builder(style: path.Style.url);
      expect(builder.basename(trace.frames.first.uri.path),
          equals('vm_test.dart'));
      expect(trace.frames.first.member, equals('getStackTraceObject'));
    });

    group('.current()', () {
      test('with no argument returns a trace starting at the current frame',
          () {
        var trace = new Trace.current();
        expect(trace.frames.first.member, equals('main.<fn>.<fn>.<fn>'));
      });

      test('at level 0 returns a trace starting at the current frame', () {
        var trace = new Trace.current(0);
        expect(trace.frames.first.member, equals('main.<fn>.<fn>.<fn>'));
      });

      test('at level 1 returns a trace starting at the parent frame', () {
        var trace = getCurrentTrace(1);
        expect(trace.frames.first.member, equals('main.<fn>.<fn>.<fn>'));
      });

      test('at level 2 returns a trace starting at the grandparent frame', () {
        var trace = nestedGetCurrentTrace(2);
        expect(trace.frames.first.member, equals('main.<fn>.<fn>.<fn>'));
      });

      test('throws an ArgumentError for negative levels', () {
        expect(() => new Trace.current(-1), throwsArgumentError);
      });
    });
  });

  group('Frame.caller()', () {
    test('with no argument returns the parent frame', () {
      expect(getCaller().member, equals('main.<fn>.<fn>'));
    });

    test('at level 0 returns the current frame', () {
      expect(getCaller(0).member, equals('getCaller'));
    });

    test('at level 1 returns the current frame', () {
      expect(getCaller(1).member, equals('main.<fn>.<fn>'));
    });

    test('at level 2 returns the grandparent frame', () {
      expect(nestedGetCaller(2).member, equals('main.<fn>.<fn>'));
    });

    test('throws an ArgumentError for negative levels', () {
      expect(() => new Frame.caller(-1), throwsArgumentError);
    });
  });
}