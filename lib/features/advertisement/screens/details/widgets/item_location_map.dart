import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/location/screens/location_map_screen.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ItemLocationMap extends StatefulWidget {
  const ItemLocationMap({required this.coordinates, super.key});

  final Coordinates? coordinates;

  @override
  State<ItemLocationMap> createState() => _ItemLocationMapState();
}

class _ItemLocationMapState extends State<ItemLocationMap> {
  LocationMapController? _locationController;
  final ValueNotifier<bool> _showMap = ValueNotifier(false);

  bool get coordinatesAvailable => widget.coordinates != null;

  @override
  void initState() {
    super.initState();
    _processCoordinates();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showMap.value = true;
      }
    });
  }

  @override
  void didUpdateWidget(covariant ItemLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _processCoordinates();
  }

  @override
  void dispose() {
    _locationController?.dispose();
    _showMap.dispose();
    super.dispose();
  }

  void _processCoordinates() {
    if (!coordinatesAvailable) return;

    final lat = widget.coordinates!.latitude.toDouble();
    final lng = widget.coordinates!.longitude.toDouble();

    _locationController ??= LocationMapController(
      initialCoordinates: LatLng(lat, lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(
      horizontal: Constant.horizontalPadding,
      vertical: 8,
    );

    if (!coordinatesAvailable)
      return Padding(
        padding: padding,
        child: AspectRatio(
          aspectRatio: 2,
          child: CustomShimmer(borderRadius: 16),
        ),
      );
    final shouldShowGoogleMap = Constant.showMap && _locationController != null;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text('location'.translate(context), style: context.titleMedium.bold),
          AspectRatio(
            aspectRatio: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder(
                      valueListenable: _showMap,
                      builder: (context, value, child) {
                        return AnimatedSwitcher(
                          switchInCurve: Curves.easeInOutCubic,
                          duration: const Duration(milliseconds: 300),
                          child: value && shouldShowGoogleMap
                              ? LocationMapWidget(
                                  key: ValueKey('map'),
                                  controller: _locationController!,
                                  showMyLocationButton: false,
                                  showMarker: false,
                                  interactive: false,
                                )
                              : CustomImage(
                                  key: ValueKey('image'),
                                  src: 'assets/map/map.png',
                                  fit: BoxFit.cover,
                                  size: context.sizeFromAspectRatio(16 / 9),
                                ),
                        );
                      },
                    ),
                  ),
                  if (!shouldShowGoogleMap)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          'viewMap'.translate(context),
                          style: context.labelMedium.withColor(
                            context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  if (_locationController != null)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              barrierDismissible: true,
                              builder: (context) {
                                return LocationMapScreen(
                                  controller: _locationController!,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
