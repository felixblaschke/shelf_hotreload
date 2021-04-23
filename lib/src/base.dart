import 'dart:async';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';

void withHotreload(FutureOr<HttpServer> Function() initializer) async {
  HttpServer? runningServer;

  var obtainNewServer = (FutureOr<HttpServer> Function() initializer) async {
    var willReplaceServer = runningServer != null;
    await runningServer?.close(force: true);
    runningServer = await initializer();

    if (willReplaceServer) {
      print('\nApplication reloaded.');
    }
  };

  try {
    await HotReloader.create(onAfterReload: (ctx) {
      obtainNewServer(initializer);
    });
    print('[shelf_hotreload] Hot reload is enabled.');
  } on StateError catch (e) {
    if (e.message.contains('VM service not available')) {
      print(
          '[shelf_hotreload] Hot reload not enabled. Run this app with --enable-vm-service (or use debug run) in order to enable hot reload.');
    } else {
      rethrow;
    }
  }

  await obtainNewServer(initializer);
}
