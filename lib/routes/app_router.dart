import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return Placeholder();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Placeholder();
      },
      branches: <StatefulShellBranch>[],
    ),
  ],
);
