// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart' as logging;

/// Provides hot-reloading ability to code that providers an http server.
///
/// Hot-reloading requires Dart VM service in order to work.
void withHotreload(
  /// Function providing a `dart:io` `HttpServer` that gets reloaded every time
  /// the code changes.
  FutureOr<HttpServer> Function() serverFactory, {

  /// Called every time the application got reloaded.
  ///
  /// If not set, it will `print()` a default message.
  FutureOr<void> Function()? onReloaded,

  /// Called once if hot-reload is enabled (e.g. VM service is available)
  ///
  /// If not set, it will `print()` a default message.
  FutureOr<void> Function()? onHotReloadAvailable,

  /// Called once if hot-reload is not available (e.g. no VM service available)
  ///
  /// If not set, it will `print()` a default message.
  FutureOr<void> Function()? onHotReloadNotAvailable,

  /// Called every time a hot reload log is recorded.
  FutureOr<void> Function(logging.LogRecord log)? onHotReloadLog,

  /// The log level to use when calling `onHotReloadLog`.
  /// By default logging is turned off.
  logging.Level logLevel = logging.Level.OFF,
}) async {
  /// Current server instance
  HttpServer? runningServer;

  /// Set default messages
  onReloaded ??= () {
    final time = DateFormat.Hms().format(DateTime.now());
    stdout.writeln('[hotreload] $time - Application reloaded.');
  };
  onHotReloadAvailable ??= () {
    stdout.writeln('[hotreload] Hot reload is enabled.');
  };
  onHotReloadNotAvailable ??= () {
    stdout.writeln(
      '[hotreload] Hot reload not enabled. Run this app with --enable-vm-service (or use debug run) in order to enable hot reload.',
    );
  };
  onHotReloadLog ??= (log) {
    final time = DateFormat.Hms().format(log.time);
    (log.level < logging.Level.SEVERE ? stdout : stderr).writeln(
      '[hotreload] $time - ${log.message}',
    );
  };

  /// Configure logging
  logging.hierarchicalLoggingEnabled = true;
  HotReloader.logLevel = logLevel;
  logging.Logger.root.onRecord.listen(onHotReloadLog);

  /// Function in charge of replacing the running http server
  final obtainNewServer = (FutureOr<HttpServer> Function() create) async {
    /// Will we replace a server?
    var willReplaceServer = runningServer != null;

    /// Shut down existing server
    await runningServer?.close(force: true);

    /// Report about reloading
    if (willReplaceServer) {
      await onReloaded!.call();
    }

    /// Create a new server
    runningServer = await create();
  };

  try {
    /// Register the server reload mechanism to the generic HotReloader.
    /// It will throw an error if reloading is not available.
    await HotReloader.create(onAfterReload: (ctx) {
      obtainNewServer(serverFactory);
    });

    /// Hot-reload is available
    await onHotReloadAvailable.call();
  } on StateError catch (e) {
    if (e.message.contains('VM service not available')) {
      /// Hot-reload is not available
      await onHotReloadNotAvailable.call();
    } else {
      rethrow;
    }
  }

  await obtainNewServer(serverFactory);
}
