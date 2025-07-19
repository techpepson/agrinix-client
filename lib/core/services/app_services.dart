import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

class AppServices {
  final FlutterSecureStorage storage = FlutterSecureStorage();
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

  Future<void> writeToStorage(String key, dynamic value) async {
    try {
      if (value == null) {
        throw ArgumentError([
          'The value argument is not provided',
          "No value provided.",
        ]);
      }

      final stringValue = (value is String) ? value : value.toString();

      await storage.write(key: key, value: stringValue);
    } catch (e) {
      throw "An error ${e.toString()} occurred while writing to secure storage.";
    }
  }

  //read from secure storage
  Future<String?> readFromSecureStorage(String key) async {
    try {
      final value = await storage.read(key: key);
      return value;
    } catch (e) {
      throw "An error ${e.toString()} occurred while reading from secure storage.";
    }
  }

  Future<void> deleteFromStorage(String key) async {
    try {
      await storage.delete(key: key);
    } catch (e) {
      throw "An error ${e.toString()} occurred while deleting from secure storage.";
    }
  }
}
