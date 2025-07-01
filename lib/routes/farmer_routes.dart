import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmerRoutes extends StatefulWidget {
  const FarmerRoutes({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<FarmerRoutes> createState() => _FarmerRoutesState();
}

class _FarmerRoutesState extends State<FarmerRoutes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        animationDuration: Duration(seconds: 2),
        surfaceTintColor: Theme.of(context).colorScheme.secondary,
        indicatorColor: Theme.of(context).primaryColor,
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected:
            (index) => widget.navigationShell.goBranch(index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(icon: Icon(Icons.eco_sharp), label: "Discover"),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: "Library",
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            label: "Capture",
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_2_outlined),
            label: "Community",
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
