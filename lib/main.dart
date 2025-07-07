import "package:flutter_dotenv/flutter_dotenv.dart";

import "package:agrinix/config/theme/app_theme.dart";
import "package:agrinix/routes/app_router.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

void main() async {
  dotenv.load(fileName: ".env");
  runApp(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        theme: appTheme,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
