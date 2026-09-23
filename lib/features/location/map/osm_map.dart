import 'package:eClassify/features/location/map/map_camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

class _OsmMapCameraController implements MapCameraController {
  _OsmMapCameraController(this._controller);

  final MapController _controller;

  @override
  void moveTo(gmaps.LatLng target, {double? zoom}) {
    _controller.move(
      ll.LatLng(target.latitude, target.longitude),
      zoom ?? _controller.camera.zoom,
    );
  }

  @override
  void moveToBounds(gmaps.LatLngBounds bounds, {double padding = 0}) {
    final fitted = CameraFit.bounds(
      bounds: LatLngBounds(
        ll.LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
        ll.LatLng(bounds.northeast.latitude, bounds.northeast.longitude),
      ),
      padding: EdgeInsets.all(padding),
    ).fit(_controller.camera);
    _controller.move(fitted.center, fitted.zoom);
  }

  @override
  Future<String?> styleError() async => null;
}

/// OpenStreetMap (via flutter_map) implementation of the swappable map
/// widget, used when `MapProviderType.freeApi` is active. See [GoogleMap]
/// for the paid counterpart.
class OsmMap extends StatefulWidget {
  const OsmMap({
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
  State<OsmMap> createState() => _OsmMapState();
}

class _OsmMapState extends State<OsmMap> {
  final MapController _controller = MapController();

  @override
  Widget build(BuildContext context) {
    final target = widget.initialCameraPosition.target;
    final circle = widget.circle;
    final marker = widget.marker;

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: ll.LatLng(target.latitude, target.longitude),
        initialZoom: widget.initialCameraPosition.zoom,
        interactionOptions: InteractionOptions(
          flags: widget.zoomGesturesEnabled
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
        onTap: widget.onTap == null
            ? null
            : (_, point) =>
                  widget.onTap!(gmaps.LatLng(point.latitude, point.longitude)),
        onMapReady: () =>
            widget.onMapCreated(_OsmMapCameraController(_controller)),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.eclassify.wrteam',
        ),
        if (circle != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: ll.LatLng(
                  circle.center.latitude,
                  circle.center.longitude,
                ),
                radius: circle.radius,
                useRadiusInMeter: true,
                color: circle.fillColor,
                borderColor: circle.strokeColor,
                borderStrokeWidth: circle.strokeWidth.toDouble(),
              ),
            ],
          ),
        if (marker != null)
          MarkerLayer(
            markers: [
              Marker(
                point: ll.LatLng(
                  marker.position.latitude,
                  marker.position.longitude,
                ),
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        const SimpleAttributionWidget(
          alignment: Alignment.bottomRight,
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }
}
