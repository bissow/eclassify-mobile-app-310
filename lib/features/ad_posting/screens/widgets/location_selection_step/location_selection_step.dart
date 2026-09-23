import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/features/item/cubits/manage_item_cubit.dart';
import 'package:eClassify/features/location/cubits/location_search_cubit.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/features/location/screens/widgets/place_api_search_bar.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/features/location/screens/widgets/location_map/location_map_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionStep extends StatefulWidget {
  const LocationSelectionStep({super.key});

  @override
  State<LocationSelectionStep> createState() => _LocationSelectionStepState();
}

class _LocationSelectionStepState extends State<LocationSelectionStep> {
  late LeafLocation _location;

  late final LocationMapController _controller;
  late final TextEditingController? _searchController;

  final bool isPaidApi = Constant.systemSettings.mapProvider.isPaidApi;

  @override
  void initState() {
    super.initState();
    final data = context.read<AdPostingCubit>().state.adPostingData;
    _location =
        data.location ?? AppSession.currentLocation ?? LeafLocation.global();
    _controller = LocationMapController(
      initialLocation: _location,
      shouldFetchInitialLocation: _location.isEmpty,
      initialCoordinates: LatLng(
        _location.latitude ?? AppConfig.defaultLatitude,
        _location.longitude ?? AppConfig.defaultLongitude,
      ),
    );
    _controller.addListener(() {
      _location = _controller.data.location;
      // To store the location in the state to pre-fill when going back and forth
      if (_location.isValid) {
        context.read<AdPostingCubit>().updateData(
          (data) => data.copyWith(location: _location),
        );
      }
    });

    if (isPaidApi) {
      _searchController = TextEditingController();
    } else {
      _searchController = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdPostingStepController.of(
      context,
    ).register(onPrevious: _onPrevious, onSubmit: _onSubmit);
  }

  void _onPrevious() {
    context.read<AdPostingCubit>().previousStep();
  }

  void _onSubmit() {
    if (!_location.isValid) {
      HelperUtils.showSnackBarMessage(context, 'Invalid Location');
      return;
    }
    context.read<AdPostingCubit>().updateData(
      (data) => data.copyWith(location: _location),
    );
    final data = context.read<AdPostingCubit>().state.adPostingData;
    context.read<ManageItemCubit>().createItem(data: data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              LocationMapWidget(controller: _controller, showCircleArea: false),
              if (isPaidApi)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  child: PlaceApiSearchBar(
                    controller: _searchController!,
                    searchOnly: true,
                    onLocationSelected: (value) {
                      context.read<LocationSearchCubit>().selectLocation(
                        placeId: value.location.placeId!,
                        sessionToken: value.sessionToken,
                      );
                    },
                  ),
                ),
              if (isPaidApi)
                Positioned.fill(
                  child: BlocConsumer<LocationSearchCubit, LocationSearchState>(
                    listener: (context, state) {
                      if (state is LocationSearchSelected) {
                        _controller.updateLocation(state.location);
                        _searchController?.clear();
                      }
                    },
                    builder: (context, state) {
                      if (state is LocationSearchSelecting) {
                        return ColoredBox(
                          color: Colors.black12,
                          child: Center(child: LoadingIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50),
          child: ColoredBox(
            color: context.colorScheme.secondary,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
                vertical: 8,
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(AppIcons.mapPin, color: context.colorScheme.primary),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_location.primaryText.isNotNullAndNotEmpty)
                              Text(
                                _location.primaryText!,
                                style: context.labelLarge,
                                maxLines: 1,
                              ),
                            if (_location.secondaryText.isNotNullAndNotEmpty)
                              Text(
                                _location.secondaryText!,
                                style: context.labelSmall.withColor(
                                  context.mutedColor,
                                ),
                                maxLines: 1,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (!isPaidApi)
                    AppButton(
                      variant: AppButtonVariant.filled,
                      size: AppButtonSize.compact,
                      width: AppButtonWidth.content,
                      backgroundColor: context.colorScheme.primary.withValues(
                        alpha: .1,
                      ),
                      foregroundColor: context.colorScheme.primary,
                      onPressed: () async {
                        final location =
                            await Navigator.of(context).pushNamed(
                                  Routes.locationScreen,
                                  arguments: {'requires_exact_location': true},
                                )
                                as LeafLocation?;
                        if (location == null) return;
                        _controller.updateLocation(location);
                      },
                      title: 'change',
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
