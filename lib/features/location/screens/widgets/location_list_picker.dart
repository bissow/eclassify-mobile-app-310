import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/location/cubits/location_cubit.dart';
import 'package:eClassify/features/location/cubits/location_search_cubit.dart';
import 'package:eClassify/features/location/models/location.dart';
import 'package:eClassify/features/location/screens/widgets/location_item.dart';
import 'package:eClassify/features/location/screens/widgets/location_search_bar.dart';
import 'package:eClassify/features/location/screens/widgets/location_shimmer.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationListPicker extends StatefulWidget {
  const LocationListPicker({this.requiresExactLocation = false, super.key});

  /// Indicates whether the user must select the most specific location level (e.g., City or Area).
  ///
  /// When set to `true`, the selection UI enforces choosing a leaf-level location
  /// rather than a higher-level region like State or Country.
  final bool requiresExactLocation;

  @override
  State<LocationListPicker> createState() => _LocationListPickerState();
}

class _LocationListPickerState extends State<LocationListPicker> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().loadCountries();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

  Widget _paginationLoadingWidget() {
    return SizedBox(
      height: 50,
      child: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          return value
              ? Center(child: LoadingIndicator())
              : const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text('location'.translate(context)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: LocationSearchBar(),
        ),
      ),
      body: _LocationSearchListWrapper(
          child: BlocConsumer<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationSelected) {
                Navigator.of(context).pop(state.location);
              }
              if (state is LocationSuccess) {
                _isLoading.value = false;
              }
            },
            builder: (context, state) {
              if (state is LocationFailure) {
                if (state.error == 'no-internet') {
                  return QErrorWidget(
                    type: QErrorType.socket,
                    onRetry: () {
                      context.read<LocationCubit>().loadCountries();
                    },
                  );
                }

                return QErrorWidget(type: QErrorType.api);
              }
              if (state is LocationSuccess) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    _LocationPathWidget(location: state.location),
                    if (!widget.requiresExactLocation)
                      LocationItem(
                        title: 'locateOnMap'.translate(context),
                        onTap: () async {
                          final location = await Navigator.of(context)
                              .pushNamed(
                                Routes.locationMapPicker,
                                arguments: {
                                  'enable_search_bar': false,
                                  'search_cubit': context
                                      .read<LocationSearchCubit>(),
                                },
                              );

                          if (location != null) {
                            Navigator.of(context).pop(location);
                          }
                        },
                        showTrailingIcon: false,
                        leadingIcon: Icon(
                          AppIcons.gpsFixFill,
                          color: context.colorScheme.primary,
                        ),
                      ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification &&
                              notification.metrics.pixels >=
                                  notification.metrics.maxScrollExtent) {
                            if (context.read<LocationCubit>().hasMore() &&
                                !_isLoading.value) {
                              context.read<LocationCubit>().loadMore();
                              _isLoading.value = true;
                            }
                          }
                          return false;
                        },
                        child: ListView.separated(
                          itemCount: state.values.length + 2,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              if (widget.requiresExactLocation) {
                                return const SizedBox.shrink();
                              }
                              final lastNode = state.location.lastNode;
                              return LocationItem(
                                title: lastNode == null
                                    ? '${'all'.translate(context)} ${'countries'.translate(context)}'
                                    : '${'allIn'.translate(context)} ${lastNode.name.localized}',
                                subtitle: null,
                                onTap: () {
                                  context
                                      .read<LocationCubit>()
                                      .selectCurrentNode();
                                },
                              );
                            } else if (index == state.values.length + 1) {
                              return _paginationLoadingWidget();
                            }

                            final location = state.values[index - 1];
                            return LocationItem(
                              title: location.name.localized,
                              subtitle: null,
                              onTap: () {
                                context.read<LocationCubit>().selectLocation(
                                  location: location,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const LocationShimmer();
            },
          ),
        ),
    );
  }
}

class _LocationPathWidget extends StatelessWidget {
  const _LocationPathWidget({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    if (location.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: context.bodyPadding(top: 10),
        children: [
          IconButton(
            constraints: BoxConstraints.tight(Size.square(30)),
            padding: EdgeInsets.zero,
            onPressed: () {
              context.read<LocationCubit>().navigateBackTo(location: null);
            },
            icon: Icon(AppIcons.mapPinFill),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              fixedSize: Size.fromHeight(30),
              iconSize: 20,
            ),
            onPressed: () {
              context.read<LocationCubit>().navigateBackTo(
                location: location.country!,
              );
            },
            icon: Icon(AppIcons.caretRight, color: context.colorScheme.primary),
            label: Text(location.country!.name.localized),
          ),
          if (location.state != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                fixedSize: Size.fromHeight(30),
                iconSize: 20,
              ),
              onPressed: () {
                context.read<LocationCubit>().navigateBackTo(
                  location: location.state!,
                );
              },
              icon: Icon(AppIcons.caretRight),
              label: Text(location.state!.name.localized),
            ),
          if (location.city != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                fixedSize: Size.fromHeight(30),
                iconSize: 20,
              ),
              onPressed: () {},
              icon: Icon(AppIcons.caretRight),
              label: Text(location.city!.name.localized),
            ),
        ],
      ),
    );
  }
}

/// A wrapper widget that abstracts away the nested [BlocBuilder] logic
/// between [LocationSearchCubit] and [LocationCubit].
///
/// This widget listens to [LocationSearchCubit] and decides whether to show the
/// search results or delegate the UI rendering to the child widget, typically
/// backed by [LocationCubit].
///
/// Helps reduce nesting and improves readability of the main screen's build method.
class _LocationSearchListWrapper extends StatelessWidget {
  const _LocationSearchListWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationSearchCubit, LocationSearchState>(
      builder: (context, state) {
        if (state is LocationSearchLoading) {
          return const LocationShimmer();
        }
        if (state is LocationSearchSuccess) {
          return ListView.separated(
            itemCount: state.locations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, index) {
              final location = state.locations[index];
              final title = location.area ?? location.city;
              return LocationItem(
                title: title!.localized,
                subtitle: [
                  if (location.area != null) ?location.city?.localized,
                  ?location.state?.localized,
                  ?location.country?.localized,
                ].join(', '),
                onTap: () {
                  Navigator.of(context).pop(location);
                },
              );
            },
          );
        }

        return child;
      },
    );
  }
}
