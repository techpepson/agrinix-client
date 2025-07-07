import 'package:geolocator/geolocator.dart';
import "dart:developer" as dev;

class AppServices {
  Future<Position> determineUserLocation() async {
    //check if permission is enabled
    bool isServiceEnabled;
    LocationPermission permission;

    isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServiceEnabled) {
      return Future.error('Location services not enabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions denied.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions denied forever.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );

    return position;
  }
}
