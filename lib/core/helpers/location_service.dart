import 'package:geolocator/geolocator.dart';

/// Thin wrapper around [Geolocator] — the device-level "is location on at
/// all" check and current-position lookup. Permission itself is handled
/// separately by `AppPermissionService`.
class AppLocationService {
  AppLocationService._();

  static Future<bool> isServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }
}
