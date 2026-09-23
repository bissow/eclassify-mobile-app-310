import 'package:eClassify/features/location/cubits/location_search_cubit.dart';
import 'package:eClassify/features/location/screens/widgets/location_list_picker.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/utils/debounce_mixin.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A simpler search bar designed for use with [LocationListPicker].
///
/// This widget includes basic search capabilities such as debouncing and API integration,
/// but avoids complex UI logic like overlays, focus-driven behavior changes, or custom
/// layout flows handled by [PlaceApiSearchBar].
///
/// Unlike [PlaceApiSearchBar], it maintains a consistent input experience—always editable,
/// always simple—making it easier to reason about and integrate.
///
/// ### Design Note
/// This widget can be promoted into a more generic `SearchBar<T>` in the future
/// if broader reuse is needed outside of location flows.
class LocationSearchBar extends StatefulWidget {
  const LocationSearchBar({super.key});

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar>
    with DebounceMixin<LocationSearchBar, String?> {
  final TextEditingController _controller = TextEditingController();

  @override
  void onDebounced(String? value) {
    context.read<LocationSearchCubit>().searchLocations(search: value);
  }

  void _onCancel() {
    _controller.clear();
    context.read<LocationSearchCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding, bottom: kToolbarHeight * .2),
      child: TextField(
        controller: _controller,
        onChanged: debounce,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText:
              '${'search'.translate(context)}\t${'location'.translate(context)}',
          prefixIcon: Icon(AppIcons.magnifyingGlass, size: 24),
          suffixIcon: IconButton(
            onPressed: _onCancel,
            icon: Icon(AppIcons.x, size: 24),
          ),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
