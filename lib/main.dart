import "package:agrinix/config/theme/app_theme.dart";
import "package:agrinix/routes/app_router.dart";
import "package:flutter/material.dart";

void main() {
  runApp(MaterialApp.router(routerConfig: router, theme: appTheme));
}
