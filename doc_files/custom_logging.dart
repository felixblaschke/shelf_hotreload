import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

class Logger {
  void log(String msg) {}
}

void main() async {
  // #begin
  final myLogger = Logger();

  withHotreload(
    () => createServer(),
    onReloaded: () => myLogger.log('Reload!'),
    onHotReloadNotAvailable: () => myLogger.log('No hot-reload :('),
    onHotReloadAvailable: () => myLogger.log('Yay! Hot-reload :)'),
  );
  // #end
}

Future<HttpServer> createServer() {
  handler(shelf.Request request) => shelf.Response.ok('hot!');
  return io.serve(handler, 'localhost', 8080);
}
