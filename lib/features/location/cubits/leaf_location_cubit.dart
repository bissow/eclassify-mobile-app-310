import 'package:eClassify/features/location/storage/location_storage.dart';
import 'dart:developer';

import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/location/repository/location_repository.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the currently selected or active [LeafLocation].
///
/// This is usually used by UI widgets like `location_widget` to reflect the
/// latest location info instantly, instead of waiting for callback-based updates.
///
/// Think of it as a live feed of "where we at right now?" in the app.
class LeafLocationCubit extends Cubit<LeafLocation?> with SessionScoped {
  LeafLocationCubit() : super(AppSession.currentLocation);

  void setLocation(LeafLocation location, {bool updateState = true}) {
    if (updateState) {
      emit(location);
    }
    AppSession.setCurrentLocation(location);
    LocationStorage.setLocation(location: location);
  }

  /// Resets in-memory location state only — deliberately does *not* go
  /// through [setLocation], which persists to Hive. `clearSessionState()`
  /// runs after `AuthStorage.clearSession()` has already wiped the `location` key
  /// on logout (see `MainActivity._endSession`); persisting here would
  /// write `{"location": {}}` straight back into the just-cleared box.
  ///
  /// Still emits: this cubit is a singleton that outlives the session
  /// (registered once at app root), so without emitting, the next guest
  /// or the next logged-in user would see the previous user's stale
  /// location via [state] until something else happened to call
  /// [setLocation] again.
  void clear() {
    final location = AppConfig.defaultLocation;
    AppSession.setCurrentLocation(location);
    emit(location);
  }

  @override
  void clearSessionState() => clear();

  /// Re-fetches the current location intelligently.
  ///
  /// Checks what data is available and picks the best option to refresh:
  /// - If `placeId` is present, fetches full details via place API.
  /// - If coordinates are available, does a reverse geocode lookup.
  /// - Otherwise, just re-emits the persisted localization info.
  ///
  /// Handy when the user changes language and we need to refresh the location in the new locale.
  void refresh() {
    // For now, we avoid refreshing the location when using the paid API until
    // we implement a reliable solution for translating item addresses.
    //
    // Currently, item addresses must be provided in English. Changing the app's language
    // will not translate these addresses for the user, as the backend doesn't store
    // translations. Translating on-the-fly would require additional Place API calls,
    // which is inefficient.
    if (state == null || Constant.systemSettings.mapProvider.isPaidApi) return;
    if (state!.placeId != null && Constant.systemSettings.mapProvider.isPaidApi) {
      _updateLocationFromPlaceId();
    } else if (state!.hasCoordinates) {
      _updateLocationFromCoordinates();
    } else {
      final location = LeafLocation(
        area: state?.area,
        city: state?.city,
        state: state?.state,
        country: state?.country,
      );
      setLocation(location);
    }
  }

  void _updateLocationFromPlaceId() async {
    try {
      final location = await LocationRepository().getLocationFromPlaceId(
        placeId: state!.placeId!,
      );
      final effectiveLocation = location.copyWith(
        radius: state?.radius ?? Constant.systemSettings.minRadius,
      );
      setLocation(effectiveLocation);
    } on Exception catch (e, stack) {
      log('$e', name: 'updateLocationFromPlaceId');
      log('$stack', name: 'updateLocationFromPlaceId');
    }
  }

  void _updateLocationFromCoordinates() async {
    try {
      final location = await LocationRepository().getLocationFromLatLng(
        latitude: state!.latitude!,
        longitude: state!.longitude!,
      );

      final effectiveLocation = LeafLocation(
        area: state!.hasArea ? location.area : null,
        city: state!.hasCity ? location.city : null,
        state: state!.hasState ? location.state : null,
        country: state!.hasCountry ? location.country : null,
        radius: state?.radius ?? Constant.systemSettings.minRadius,
        latitude: state!.latitude,
        longitude: state!.longitude,
        placeId: state!.placeId,
      );
      setLocation(effectiveLocation);
    } on Exception catch (e, stack) {
      log('$e', name: 'updateLocationFromCoordinates');
      log('$stack', name: 'updateLocationFromCoordinates');
    }
  }
}
