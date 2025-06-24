import "package:agrinix/screens/auth/login.dart";
import "package:agrinix/screens/auth/register.dart";
import "package:agrinix/screens/onboarding/onboarding_screen.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return Login();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return Register();
      },
    ),
    GoRoute(
      path: '/onboard',
      builder: (context, state) {
        return OnboardingScreen();
      },
    ),
  ],
);
