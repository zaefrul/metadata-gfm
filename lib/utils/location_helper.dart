import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  bool get hasValidCoordinates => isValidCoordinatePair(latitude, longitude);

  /// A live GPS fix — not a cached / 0,0 / empty value.
  bool get isFreshFix => hasValidCoordinates && !fromCache;
}

const _locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  timeLimit: Duration(seconds: 15),
);

Future<LocationFetchResult> resolveDeviceLocation(
    {bool forceRefresh = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedLat = prefs.getString(prefsLATITUDE);
  final cachedLng = prefs.getString(prefsLONGITUDE);

  if (!forceRefresh && isValidCoordinatePair(cachedLat, cachedLng)) {
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
        fromCache: isValidCoordinatePair(cachedLat, cachedLng),
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
        fromCache: isValidCoordinatePair(cachedLat, cachedLng),
      );
    }

    Position? position;
    if (!forceRefresh) {
      position = await Geolocator.getLastKnownPosition();
      if (position != null &&
          !isValidCoordinatePair(
            position.latitude.toString(),
            position.longitude.toString(),
          )) {
        position = null;
      }
    }
    position ??=
        await Geolocator.getCurrentPosition(locationSettings: _locationSettings);

    final lat = position.latitude.toString();
    final lng = position.longitude.toString();

    if (!isValidCoordinatePair(lat, lng)) {
      return LocationFetchResult(
        latitude: cachedLat ?? '0.0',
        longitude: cachedLng ?? '0.0',
        status: LocationStatus.unavailable,
        fromCache: isValidCoordinatePair(cachedLat, cachedLng),
      );
    }

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
      fromCache: isValidCoordinatePair(cachedLat, cachedLng),
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

String locationRequiredMessage(LocationFetchResult location) {
  final message = describeLocationFailure(location.status);
  if (message.isNotEmpty) return message;
  if (location.fromCache) {
    return 'We could not refresh your GPS. Please enable location and try again.';
  }
  return 'GPS coordinates are required. Please enable location and try again in an area with good GPS.';
}

/// Resolves GPS, and if location is off or permission is denied, prompts the
/// user to allow it again (system sheet) or open Settings.
Future<LocationFetchResult> resolveDeviceLocationOrPrompt(
  BuildContext context, {
  bool forceRefresh = false,
  bool requireFresh = false,
}) async {
  var location = await resolveDeviceLocation(forceRefresh: forceRefresh);
  if (_isAcceptable(location, requireFresh)) {
    return location;
  }

  final outcome = await _promptToFixLocation(context, location);
  if (outcome == _LocationPromptResult.granted && context.mounted) {
    location = await resolveDeviceLocation(forceRefresh: forceRefresh);
  }
  return location;
}

bool _isAcceptable(LocationFetchResult location, bool requireFresh) {
  return requireFresh ? location.isFreshFix : location.hasValidCoordinates;
}

enum _LocationPromptResult { granted, openedSettings, dismissed, none }

Future<_LocationPromptResult> _promptToFixLocation(
  BuildContext context,
  LocationFetchResult location,
) async {
  if (!context.mounted) return _LocationPromptResult.none;

  if (location.status == LocationStatus.serviceDisabled) {
    final open = await _confirmOpenSettings(
      context,
      title: 'Location is turned off',
      message:
          'GEMS needs GPS to continue. Please turn on Location Services, then try again.',
      actionLabel: 'Turn on',
    );
    if (open == true) {
      await Geolocator.openLocationSettings();
      return _LocationPromptResult.openedSettings;
    }
    return _LocationPromptResult.dismissed;
  }

  if (location.status == LocationStatus.permissionDenied) {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      final open = await _confirmOpenSettings(
        context,
        title: 'Allow location access',
        message:
            'Location permission is blocked for GEMS. Please allow it in Settings, then try again.',
        actionLabel: 'Open Settings',
      );
      if (open == true) {
        await Geolocator.openAppSettings();
        return _LocationPromptResult.openedSettings;
      }
      return _LocationPromptResult.dismissed;
    }

    final allow = await _confirmOpenSettings(
      context,
      title: 'Allow location access',
      message:
          'GEMS needs location permission to attach GPS to work orders. Please allow access to continue.',
      actionLabel: 'Allow',
    );
    if (allow != true) return _LocationPromptResult.dismissed;

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return _LocationPromptResult.granted;
    }

    await Geolocator.openAppSettings();
    return _LocationPromptResult.openedSettings;
  }

  if (!context.mounted) return _LocationPromptResult.none;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Location unavailable'),
      content: Text(locationRequiredMessage(location)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  return _LocationPromptResult.none;
}

Future<bool?> _confirmOpenSettings(
  BuildContext context, {
  required String title,
  required String message,
  required String actionLabel,
}) {
  if (!context.mounted) return Future.value(false);
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

/// Rejects null/empty/non-numeric values, (0,0), and out-of-range lat/lng.
bool isValidCoordinatePair(String? lat, String? lng) {
  if (lat == null || lng == null) return false;
  final parsedLat = double.tryParse(lat.trim());
  final parsedLng = double.tryParse(lng.trim());
  if (parsedLat == null || parsedLng == null) return false;
  if (parsedLat == 0.0 && parsedLng == 0.0) return false;
  if (parsedLat.abs() > 90 || parsedLng.abs() > 180) return false;
  return true;
}
