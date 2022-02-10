import 'dart:async';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:intl/intl.dart';

void withHotreload(FutureOr<HttpServer> Function() initializer) async {
  HttpServer? runningServer;

  // ignore: prefer_function_declarations_over_variables
  var obtainNewServer = (FutureOr<HttpServer> Function() initializer) async {
    var willReplaceServer = runningServer != null;
    await runningServer?.close(force: true);
    if (willReplaceServer) {
      var time = DateFormat.Hms().format(DateTime.now());
      print('[hotreload] $time - Application reloaded.');
    }
    runningServer = await initializer();
  };

  try {
    await HotReloader.create(onAfterReload: (ctx) {
      obtainNewServer(initializer);
    });
    print('[hotreload] Hot reload is enabled.');
  } on StateError catch (e) {
    if (e.message.contains('VM service not available')) {
      print(
          '[hotreload] Hot reload not enabled. Run this app with --enable-vm-service (or use debug run) in order to enable hot reload.');
    } else {
      rethrow;
    }
  }

  await obtainNewServer(initializer);
}
