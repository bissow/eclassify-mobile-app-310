import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Provider-agnostic handle for issuing camera commands to whichever map
/// widget ([GoogleMap] or [OsmMap]) is currently rendered, so callers like
/// `LocationMapController` don't need to know which SDK is active.
abstract class MapCameraController {
  void moveTo(LatLng target, {double? zoom});

  void moveToBounds(LatLngBounds bounds, {double padding = 0});

  Future<String?> styleError();
}
