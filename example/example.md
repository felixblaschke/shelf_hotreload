```dart
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

// Run this app with --enable-vm-service (or use debug run)
void main() async {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() {
  var handler = (shelf.Request request) => shelf.Response.ok('hot!');
  return io.serve(handler, 'localhost', 8080);
}
```
