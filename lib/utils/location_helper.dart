import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reference.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  unavailable,
}

class LocationFetchResult {
  final String latitude;
  final String longitude;
  final LocationStatus status;
  final bool fromCache;

  const LocationFetchResult({
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.fromCache,
  });

  bool get hasValidCoordinates => latitude != '0.0' || longitude != '0.0';
}

Future<LocationFetchResult> resolveDeviceLocation(
    {bool forceRefresh = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedLat = prefs.getString(prefsLATITUDE);
  final cachedLng = prefs.getString(prefsLONGITUDE);

  if (!forceRefresh && _isValid(cachedLat, cachedLng)) {
    return LocationFetchResult(
      latitude: cachedLat!,
      longitude: cachedLng!,
      status: LocationStatus.success,
      fromCache: true,
    );
  }

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationFetchResult(
        latitude: cachedLat ?? '0.0',
        longitude: cachedLng ?? '0.0',
        status: LocationStatus.serviceDisabled,
        fromCache: cachedLat != null && cachedLng != null,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return LocationFetchResult(
        latitude: cachedLat ?? '0.0',
        longitude: cachedLng ?? '0.0',
        status: LocationStatus.permissionDenied,
        fromCache: cachedLat != null && cachedLng != null,
      );
    }

    Position? position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition();

    final lat = position.latitude.toString();
    final lng = position.longitude.toString();

    await prefs.setString(prefsLATITUDE, lat);
    await prefs.setString(prefsLONGITUDE, lng);

    return LocationFetchResult(
      latitude: lat,
      longitude: lng,
      status: LocationStatus.success,
      fromCache: false,
    );
  } catch (err, st) {
    debugPrint('Failed to resolve device location: $err\n$st');
    return LocationFetchResult(
      latitude: cachedLat ?? '0.0',
      longitude: cachedLng ?? '0.0',
      status: LocationStatus.unavailable,
      fromCache: cachedLat != null && cachedLng != null,
    );
  }
}

String describeLocationFailure(LocationStatus status) {
  switch (status) {
    case LocationStatus.serviceDisabled:
      return 'Location services are turned off. Please enable them to attach GPS data.';
    case LocationStatus.permissionDenied:
      return 'Location permission is disabled for GEMS. Please allow access in Settings.';
    case LocationStatus.unavailable:
      return 'We could not determine your location. Please try again in a moment.';
    case LocationStatus.success:
      return '';
  }
}

bool _isValid(String? lat, String? lng) {
  if (lat == null || lng == null) return false;
  if (lat == '0.0' && lng == '0.0') return false;
  return true;
}
