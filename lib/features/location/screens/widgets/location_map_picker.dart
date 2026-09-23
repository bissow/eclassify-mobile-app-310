import 'dart:math';

import 'package:eClassify/features/location/cubits/location_search_cubit.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/location/screens/widgets/place_api_search_bar.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationMapPicker extends StatefulWidget {
  const LocationMapPicker({this.enableSearchBar = true, super.key});

  final bool enableSearchBar;

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider.value(
        value: args['search_cubit'] as LocationSearchCubit,
        child: LocationMapPicker(
          enableSearchBar: args['enable_search_bar'] as bool? ?? true,
        ),
      ),
    );
  }
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  final minRadius = Constant.systemSettings.minRadius.toDouble();
  final maxRadius = Constant.systemSettings.maxRadius.toDouble();

  final LocationMapController _controller = LocationMapController(
    autoZoom: true,
  );
  final TextEditingController _searchController = TextEditingController();
  late final ValueNotifier<double> _radiusNotifier = ValueNotifier(minRadius);

  bool get _hasValidRadiusRange => minRadius < maxRadius;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Set the persisted radius from Hive once the controller is ready.
      //
      // If the current radius equals [minRadius], update it with the
      // controller's latest radius value (usually restored from persistence).
      if (_radiusNotifier.value == minRadius) {
        _radiusNotifier.value = max(_controller.radius.toDouble(), minRadius);
      }

      // Update the search bar text with the currently selected location.
      //
      // Triggered when the user taps on the map and the controller is ready.
      // Falls back to displaying "Global" if no location is selected.
      if (_controller.isReady) {
        final location = _controller.data.location;
        _searchController.text = location.isEmpty
            ? 'searchCity'.translate(context)
            : location.localizedPath;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _radiusNotifier.dispose();
    super.dispose();
  }

  Widget _radiusSelector() {
    return ValueListenableBuilder(
      valueListenable: _radiusNotifier,
      builder: (context, value, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'selectAreaRange'.translate(context),
                  style: context.titleMedium,
                ),
                Text(
                  '${value.toInt()} ${"km".translate(context)}',
                  style: context.titleMedium,
                ),
              ],
            ),
            20.vGap,
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 10,
                activeTrackColor: context.colorScheme.primary,
                inactiveTrackColor: context.colorScheme.primary.withValues(
                  alpha: .2,
                ),
                thumbColor: context.colorScheme.primary,
                padding: EdgeInsets.zero,
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: Slider(
                value: value,
                min: minRadius.toDouble(),
                max: maxRadius.toDouble(),
                divisions: (maxRadius - minRadius).toInt(),
                onChanged: (value) =>
                    _radiusNotifier.value = value.roundToDouble(),
                onChangeEnd: _controller.updateRadius,
                label: '${value.toInt()}',
              ),
            ),
            5.vGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${minRadius.toInt()}\t${"km".translate(context)}',
                  style: context.titleSmall,
                ),
                Text(
                  '${maxRadius.toInt()}\t${"km".translate(context)}',
                  style: context.titleSmall,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('nearbyListings'.translate(context)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: PlaceApiSearchBar(
            enabled: widget.enableSearchBar,
            controller: _searchController,
            onLocationSelected: (value) {
              _searchController.text = value.location.localizedPath;
              context.read<LocationSearchCubit>().selectLocation(
                placeId: value.location.placeId!,
                sessionToken: value.sessionToken,
              );
            },
          ),
        ),
        actions: [
          AppButton(
            variant: AppButtonVariant.text,
            width: AppButtonWidth.content,
            size: AppButtonSize.compact,
            foregroundColor: context.colorScheme.primary,
            onPressed: () {
              Navigator.of(context).pop(LeafLocation.global());
            },
            title: 'reset',
          ),
        ],
      ),
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          if (_hasValidRadiusRange) _radiusSelector(),
          AppButton(
            variant: AppButtonVariant.filled,
            onPressed: () {
              Navigator.of(context).pop(_controller.data.location);
            },
            title: 'apply',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: LocationMapWidget(controller: _controller)),
          BlocConsumer<LocationSearchCubit, LocationSearchState>(
            listener: (context, state) {
              if (state is LocationSearchSelected) {
                _controller.updateLocation(state.location);
              }
            },
            builder: (context, state) {
              if (state is LocationSearchSelecting) {
                return ColoredBox(
                  color: Colors.black12,
                  child: Center(child: LoadingIndicator()),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
