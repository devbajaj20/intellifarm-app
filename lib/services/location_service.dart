import 'package:location/location.dart';

class LocationService {
  static final Location _location = Location();

  static Future<LocationData?> getCurrentLocation() async {
    try {
      // 1️⃣ Check service
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      // 2️⃣ Check permission
      PermissionStatus permissionGranted =
      await _location.hasPermission();

      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
      }

      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        return null;
      }

      // 3️⃣ Get location
      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }
}
