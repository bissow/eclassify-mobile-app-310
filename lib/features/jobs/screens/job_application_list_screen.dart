import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/jobs/cubits/change_job_application_status_cubit.dart';
import 'package:eClassify/features/jobs/cubits/fetch_job_application_cubit.dart';
import 'package:eClassify/features/jobs/models/job_application.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class JobApplicationListScreen extends StatefulWidget {
  final int? itemId;
  final bool? isMyJobApplications;

  const JobApplicationListScreen({
    Key? key,
    this.itemId,
    this.isMyJobApplications = false,
  }) : super(key: key);

  @override
  _JobApplicationListScreenState createState() =>
      _JobApplicationListScreenState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ChangeJobApplicationStatusCubit()),
          BlocProvider(create: (context) => FetchJobApplicationCubit()),
        ],
        child: JobApplicationListScreen(
          itemId: args?['itemId'] as int?,
          isMyJobApplications: args?['isMyJobApplications'] ?? false,
        ),
      ),
    );
  }
}

class _JobApplicationListScreenState extends State<JobApplicationListScreen> {
  late final ScrollController _pageScrollController = ScrollController();
  List<JobApplication> applications = [];

  @override
  void initState() {
    super.initState();
    if (AppSession.isAuthenticated) {
      context.read<FetchJobApplicationCubit>().fetchApplications(
        itemId: widget.itemId,
        isMyJobApplications: widget.isMyJobApplications ?? false,
      );
      _pageScrollController.addListener(_pageScroll);
    }
  }

  void _pageScroll() {
    // Detect near-bottom instead of exact end to reduce repeated triggers.
    final position = _pageScrollController.position;
    final isEndReached =
        _pageScrollController.hasClients &&
        !position.outOfRange &&
        position.extentAfter < 400;
    if (isEndReached) {
      if (context.read<FetchJobApplicationCubit>().hasMoreData()) {
        context.read<FetchJobApplicationCubit>().fetchMyMoreapplications(
          itemId: widget.itemId,
          isMyJobApplications: widget.isMyJobApplications ?? false,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.isMyJobApplications == true
              ? "myJobApplications".translate(context)
              : "jobApplications".translate(context),
        ),
      ),
      body: BlocConsumer<FetchJobApplicationCubit, FetchJobApplicationState>(
        listener: (context, state) {
          if (state is FetchJobApplicationSuccess) {
            applications = state.applications;
          }
        },
        builder: (context, state) {
          if (state is FetchJobApplicationInProgress) {
            return Center(
              child: CircularProgressIndicator(
                color: context.colorScheme.primary,
              ),
            );
          }

          if (state is FetchJobApplicationFailed) {
            return QErrorWidget(
              error: state.error,
              onRetry: () {
                context.read<FetchJobApplicationCubit>().fetchApplications(
                  itemId: widget.itemId,
                  isMyJobApplications: widget.isMyJobApplications ?? false,
                );
              },
            );
          }

          if (state is FetchJobApplicationSuccess) {
            if (state.applications.isEmpty) {
              return QErrorWidget.emptyData();
            }
            return BlocListener<
              ChangeJobApplicationStatusCubit,
              ChangeJobApplicationStatusState
            >(
              listener: (context, state) {
                if (state is ChangeJobApplicationStatusSuccess) {
                  HelperUtils.showSnackBarMessage(context, state.message);
                  setState(() {
                    final index = applications.indexWhere(
                      (app) => app.id == state.id,
                    );
                    if (index != -1) {
                      applications[index].status = state.status;
                    }
                  });
                } else if (state is ChangeJobApplicationStatusFailure) {
                  HelperUtils.showSnackBarMessage(context, state.errorMessage);
                }
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _pageScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final app = applications[index];
                        return Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          shadowColor: Colors.grey.withValues(alpha: 0.5),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isMyJobApplications == true
                                      ? '${"adTitle".translate(context)}: ${app.item?.name?.localized ?? ''}'
                                      : '${"fullName".translate(context)}: ${app.fullName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                ),
                                Text(
                                  widget.isMyJobApplications == true
                                      ? '${"recruiter".translate(context)}: ${app.recruiter?.name ?? ''}'
                                      : '${"emailAddress".translate(context)}: ${app.email}',
                                  style: TextStyle(height: 2),
                                ),
                                if (widget.isMyJobApplications == false)
                                  Text(
                                    '${"mobileNumber".translate(context)}: ${app.contact.number}',
                                    style: TextStyle(height: 2),
                                  ),
                                const SizedBox(height: 8),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (app.resume != null &&
                                        app.resume!.isNotEmpty)
                                      _FileWidget(url: app.resume!),
                                    if (widget.isMyJobApplications == false &&
                                        app.status == 'pending')
                                      BlocBuilder<
                                        ChangeJobApplicationStatusCubit,
                                        ChangeJobApplicationStatusState
                                      >(
                                        builder: (context, state) {
                                          return IgnorePointer(
                                            ignoring:
                                                state
                                                    is ChangeJobApplicationStatusInProgress,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              spacing: 10,
                                              children: [
                                                acceptRejectButtonWidget(
                                                  'Accept',
                                                  AppIcons.check,
                                                  app.id,
                                                  'accepted',
                                                ),
                                                acceptRejectButtonWidget(
                                                  'reject',
                                                  AppIcons.x,
                                                  app.id,
                                                  'rejected',
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      Text(
                                        app.status?.translate(context) ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: app.status == 'accepted'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore) LoadingIndicator(),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget acceptRejectButtonWidget(
    String btnTitle,
    IconData icon,
    int appid,
    String updateStatus,
  ) {
    return Expanded(
      child: AppButton(
        variant: AppButtonVariant.filled,
        onPressed: () => updateApplicationStatus(appid, updateStatus),
        icon: Icon(icon),
        title: btnTitle,
        backgroundColor: updateStatus == 'accepted'
            ? Colors.green.shade50
            : Colors.red.shade50,
        foregroundColor: updateStatus == 'accepted' ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: updateStatus == 'accepted' ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Future<void> updateApplicationStatus(int id, String newStatus) async {
    context.read<ChangeJobApplicationStatusCubit>().changeJobApplicationStatus(
      id: id,
      status: newStatus,
    );
  }
}

class _FileWidget extends StatefulWidget {
  final String url;

  const _FileWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<_FileWidget> createState() => _FileWidgetState();
}

class _FileWidgetState extends State<_FileWidget> {
  bool isDownloading = false;
  double downloadProgress = 0;

  Future<void> _viewFile() async {
    final extension = widget.url.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      Navigator.pushNamed(
        context,
        Routes.pdfViewerScreen,
        arguments: {'url': widget.url},
      );
    } else {
      // For DOCX and others, download then open
      setState(() {
        isDownloading = true;
      });
      try {
        final dir = await getApplicationDocumentsDirectory();
        final filename = path.basename(widget.url);
        final savePath = '${dir.path}/$filename';
        final file = File(savePath);

        if (!await file.exists()) {
          await Api.download(
            url: widget.url,
            savePath: savePath,
            onUpdate: (progress) {
              setState(() {
                downloadProgress = progress;
              });
            },
          );
        }
        await OpenFile.open(savePath);
      } catch (e) {
        if (mounted) {
          HelperUtils.showSnackBarMessage(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            isDownloading = false;
            downloadProgress = 0;
          });
        }
      }
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      isDownloading = true;
    });
    try {
      final filename = path.basename(widget.url);
      final response = await Dio().get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = (count / total) * 100;
            });
          }
        },
      );

      await FilePicker.saveFile(fileName: filename, bytes: response.data);
    } catch (e) {
      if (mounted) {
        HelperUtils.showSnackBarMessage(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
          downloadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(widget.url);
    return Container(
      constraints: BoxConstraints(maxWidth: context.screenWidth),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: .05),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.fileFill, color: context.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (isDownloading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: downloadProgress > 0 ? downloadProgress / 100 : null,
                strokeWidth: 2,
                color: context.colorScheme.primary,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _viewFile,
                  icon: Icon(AppIcons.eye, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'view'.translate(context),
                ),
                IconButton(
                  onPressed: _downloadFile,
                  icon: Icon(AppIcons.downloadSimple, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'download'.translate(context),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
