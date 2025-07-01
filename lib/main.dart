import "dart:async";
import "dart:developer" as dev;
import "package:flutter_dotenv/flutter_dotenv.dart";

import "package:agrinix/config/theme/app_theme.dart";
import "package:agrinix/routes/app_router.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

void main() async {
  dotenv.load(fileName: ".env");
  runZonedGuarded(
    () {
      FlutterError.onError = (FlutterErrorDetails details) {
        // Catch Flutter framework errors
        FlutterError.presentError(details); // show red screen in debug
        // You can log this to a file, service, etc.
        dev.log('Caught by FlutterError.onError: ${details.exception}');
      };
      runApp(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: appTheme,
            debugShowCheckedModeBanner: false,
          ),
        ),
      );
    },
    (Object error, StackTrace trace) {
      dev.log("Caught by runZoned exception $error");
    },
  );
}
