import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/features/location/map/google_map.dart';
import 'package:eClassify/features/location/map/map_camera_controller.dart';
import 'package:eClassify/features/location/map/osm_map.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Provider-agnostic map widget. Renders [OsmMap] or [GoogleMap] depending on
/// `Constant.systemSettings.mapProvider`, so callers don't branch on it themselves.
class AppMap extends StatelessWidget {
  const AppMap({
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
    return Constant.systemSettings.mapProvider.isFreeApi
        ? OsmMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: onMapCreated,
            circle: circle,
            marker: marker,
            onTap: onTap,
            zoomGesturesEnabled: zoomGesturesEnabled,
          )
        : GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: onMapCreated,
            circle: circle,
            marker: marker,
            onTap: onTap,
            zoomGesturesEnabled: zoomGesturesEnabled,
          );
  }
}
