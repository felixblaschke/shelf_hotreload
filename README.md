<!-- This file uses generated code. Visit https://pub.dev/packages/readme_helper for usage information. -->

# shelf_hotreload

Wrapper to easily enable hot-reload for shelf applications.

## Usage

<!-- #code doc_files/example.dart -->
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
  handler(shelf.Request request) => shelf.Response.ok('hot!');
  return io.serve(handler, 'localhost', 8080);
}
```
<!-- // end of #code -->

In order to enable hot-reload, you need to run your Dart application with `--enable-vm-service` (or use _debug run_ in your IDE).

For example:

```
dart run --enable-vm-service path/to/app.dart
```

### Custom logging

You can also also modify the default logging by providing callbacks:

<!-- #code doc_files/custom_logging.dart -->
```dart
final myLogger = Logger();

withHotreload(
  () => createServer(),
  onReloaded: () => myLogger.log('Reload!'),
  onHotReloadNotAvailable: () => myLogger.log('No hot-reload :('),
  onHotReloadAvailable: () => myLogger.log('Yay! Hot-reload :)'),
  onHotReloadLog: (log) => myLogger.log('Reload Log: ${log.message}'),
  logLevel: Level.INFO,
);
```
<!-- // end of #code -->
