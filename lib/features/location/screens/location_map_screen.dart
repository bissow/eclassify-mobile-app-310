import 'package:eClassify/features/location/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_widget.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';

class LocationMapScreen extends StatelessWidget {
  const LocationMapScreen({super.key, required this.controller});

  final LocationMapController controller;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: LocationMapWidget(
        controller: controller,
        showMyLocationButton: false,
        showMarker: false,
      ),
    );
  }
}
