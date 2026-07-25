import 'package:permission_handler/permission_handler.dart';

/// Static per-permission helpers — always check status before calling
/// `.request()`, per project convention.
class AppPermissionService {
  AppPermissionService._();

  static Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted || status.isLimited;
  }

  /// Requests location permission if not already granted. Returns `true`
  /// only if the permission ends up granted (or limited).
  static Future<bool> requestLocationPermission() async {
    if (await hasLocationPermission()) {
      return true;
    }
    final status = await Permission.location.request();
    return status.isGranted || status.isLimited;
  }

  static Future<bool> openSettings() => openAppSettings();
}
