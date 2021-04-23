Wrapper to easily enable hot-reload for shelf applications. 

## Usage

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


In order to enable hot-reload, you need to run your Dart application with `--enable-vm-service`. For example:
```
dart --enable-vm-service path/to/app.dart
```

**Important:** Your app will work nevertheless, even if you omit the flag.
