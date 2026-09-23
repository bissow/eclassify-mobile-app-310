import 'package:eClassify/core/utils/map_style.dart';
import 'package:eClassify/features/location/map/map_camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class _GoogleMapCameraController implements MapCameraController {
  _GoogleMapCameraController(this._controller);

  final gmaps.GoogleMapController _controller;

  @override
  void moveTo(gmaps.LatLng target, {double? zoom}) {
    _controller.animateCamera(gmaps.CameraUpdate.newLatLng(target));
  }

  @override
  void moveToBounds(gmaps.LatLngBounds bounds, {double padding = 0}) {
    _controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  @override
  Future<String?> styleError() => _controller.getStyleError();
}

/// Google Maps implementation of the swappable map widget. See [OsmMap] for
/// the free-tier counterpart selected via `MapProviderType`.
class GoogleMap extends StatelessWidget {
  const GoogleMap({
    required this.initialCameraPosition,
    required this.onMapCreated,
    this.circle,
    this.marker,
    this.onTap,
    this.zoomGesturesEnabled = true,
    super.key,
  });

  final gmaps.CameraPosition initialCameraPosition;
  final void Function(MapCameraController controller) onMapCreated;
  final gmaps.Circle? circle;
  final gmaps.Marker? marker;
  final void Function(gmaps.LatLng coordinates)? onTap;
  final bool zoomGesturesEnabled;

  @override
  Widget build(BuildContext context) {
    return gmaps.GoogleMap(
      initialCameraPosition: initialCameraPosition,
      onMapCreated: (controller) =>
          onMapCreated(_GoogleMapCameraController(controller)),
      circles: {if (circle != null) circle!},
      markers: {if (marker != null) marker!},
      onTap: onTap,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: zoomGesturesEnabled,
      compassEnabled: false,
      indoorViewEnabled: true,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      style: MapStyle.style,
    );
  }
}
