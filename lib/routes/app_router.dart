import "package:agrinix/routes/farmer_routes.dart";
import "package:agrinix/screens/auth/login.dart";
import "package:agrinix/screens/auth/register.dart";
import "package:agrinix/screens/capture/capture_screen.dart";
import "package:agrinix/screens/community/community_session.dart";
import "package:agrinix/screens/community/create_message.dart";
import "package:agrinix/screens/community/message_details.dart";
import "package:agrinix/screens/discover/discover_screen.dart";
import "package:agrinix/screens/discover/single_pest_info.dart";
import "package:agrinix/screens/library/crop_library.dart";
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

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return FarmerRoutes(navigationShell: navigationShell);
      },
      branches: [
        //discover branch
        StatefulShellBranch(
          initialLocation: '/discover',
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) {
                return FutureBuilder(
                  future: Future.delayed(Duration(seconds: 10)),
                  builder: (context, snapshot) {
                    return DiscoverScreen();
                  },
                );
              },
              routes: [
                GoRoute(
                  path: 'pest/:id',
                  builder: (context, state) {
                    final pestData = state.extra as Map<String, dynamic>;
                    return SinglePestInfo(pestData: pestData);
                  },
                ),
              ],
            ),
          ],
        ),

        //capture branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) {
                return FutureBuilder(
                  future: Future.delayed(Duration(seconds: 10)),
                  builder: (context, snapshot) {
                    return CropLibrary();
                  },
                );
              },
            ),
          ],
        ),

        //library branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/capture',
              builder: (context, state) {
                return FutureBuilder(
                  future: Future.delayed(Duration(seconds: 10)),
                  builder: (context, snapshot) {
                    return CaptureScreen();
                  },
                );
              },
            ),
          ],
        ),

        //community branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) {
                return FutureBuilder(
                  future: Future.delayed(Duration(seconds: 10)),
                  builder: (context, snapshot) {
                    return CommunitySession();
                  },
                );
              },
              routes: [
                GoRoute(
                  path: 'message-details',
                  builder: (context, state) {
                    return FutureBuilder(
                      future: Future.delayed(Duration(seconds: 5)),
                      builder: (context, snapshot) {
                        return MessageDetails();
                      },
                    );
                  },
                ),
                GoRoute(
                  path: 'create-message',
                  builder: (context, state) {
                    return FutureBuilder(
                      future: Future.delayed(Duration(seconds: 5)),
                      builder: (context, snapshot) {
                        return CreateMessage();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        //settings branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) {
                return FutureBuilder(
                  future: Future.delayed(Duration(seconds: 10)),
                  builder: (context, snapshot) {
                    return DiscoverScreen();
                  },
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
