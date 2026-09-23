import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter/foundation.dart';

class BackgroundUploadUtility {
  static const String uploadGroup = 'item_media_upload';

  // FileDownloader().updates is a single-subscription stream — only one
  // listener is allowed on it for the app's whole lifetime. Multiple
  // ReelViewWidgets (or anything else) calling
  // listenForItemUploadCompletion independently would each try to listen
  // to it directly and the second one throws "Stream has already been
  // listened to." Subscribe to it exactly once here, and fan updates out
  // to callers through this broadcast stream instead.
  static StreamSubscription<TaskUpdate>? _updatesSubscription;
  static final StreamController<TaskUpdate> _updatesController =
      StreamController<TaskUpdate>.broadcast();

  static void _ensureListeningToUpdates() {
    if (_updatesSubscription != null) return;
    try {
      _updatesSubscription = FileDownloader().updates.listen(
        _updatesController.add,
        onError: _updatesController.addError,
      );
    } on StateError catch (e, st) {
      // FileDownloader().updates is a plain Dart singleton stream — a hot
      // reload (not restart) during development keeps it alive with its
      // previous subscription attached while resetting this class's static
      // fields, so this guard can still race a stale listener. Degrade
      // instead of crashing the app: reel processing indicators simply
      // won't auto-refresh on upload completion until next cold start.
      Log.error(
        'BackgroundUploadUtility failed to subscribe to upload updates',
        e,
        st,
      );
    }
  }

  /// Initialises notification configurations for the background downloader.
  static Future<void> initialize() async {
    await FileDownloader().configureNotificationForGroup(
      uploadGroup,
      running: const TaskNotification(
        'Uploading media',
        'Uploading {filename} {progress}',
      ),
      complete: const TaskNotification(
        'Upload complete',
        'All media files uploaded successfully',
      ),
      error: const TaskNotification(
        'Upload failed',
        'Failed to upload {filename}',
      ),
      progressBar: true,
      groupNotificationId: 'item_media_upload_notification',
    );
  }

  /// Uploads media files in the background using the background_downloader package.
  ///
  /// [itemId] is the ID of the posted item.
  /// [files] is a map of form fields (e.g. 'product_video') to their local file paths.
  static Future<void> uploadMedia({
    required String itemId,
    required Map<String, String> files,
  }) async {
    Log.info(
      'Uploading media in background for item $itemId with files $files',
    );
    final token = AppSession.jwtToken;
    final url = '${Api.baseUrl}${ApiEndpoints.uploadMedia}';

    if (files.isEmpty) return;

    try {
      final multiTask = MultiUploadTask(
        url: url,
        files: files.entries.map((e) => (e.key, e.value)).toList(),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        fields: {'item_id': itemId},
        group: uploadGroup,
        updates: Updates.statusAndProgress,
        // Lets listenForItemUploadCompletion identify which item a given
        // task update belongs to without depending on the upload fields.
        metaData: itemId,
      );

      Log.info('Enqueuing MultiUploadTask for item $itemId');

      await FileDownloader().enqueue(multiTask).catchError((error) {
        Log.error(error.toString(), error, null);
        return false;
      });
    } catch (e, st) {
      Log.error(e.toString(), e, st);
    }
  }

  /// Notifies [onComplete] once the background upload for [itemId] finishes.
  ///
  /// The caller owns the returned subscription — cancel it once [onComplete]
  /// fires (or on dispose) rather than relying on this to unsubscribe itself.
  static StreamSubscription<TaskUpdate> listenForItemUploadCompletion({
    required String itemId,
    required VoidCallback onComplete,
  }) {
    _ensureListeningToUpdates();
    return _updatesController.stream.listen((update) {
      if (update is! TaskStatusUpdate) return;
      if (update.task.group != uploadGroup) return;
      if (update.task.metaData != itemId) return;
      if (update.status != TaskStatus.complete) return;

      onComplete();
    });
  }
}
