import 'dart:io';

import 'package:eClassify/features/subscription/cubits/payment_receipt_cubit.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TransactionReceiptScreen extends StatefulWidget {
  const TransactionReceiptScreen({
    required this.transactionId,
    required this.transactionOrderId,
    super.key,
  });

  final int transactionId;
  final String transactionOrderId;

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (context) => BlocProvider(
        create: (context) => PaymentReceiptCubit(),
        child: TransactionReceiptScreen(
          transactionId: arguments['transactionId'],
          transactionOrderId: arguments['transactionOrderId'],
        ),
      ),
    );
  }
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  late final WebViewController _controller;
  String _htmlContent = "";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xffffffff))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) {
            return NavigationDecision.prevent;
          },
        ),
      );
    context.read<PaymentReceiptCubit>().fetchReceipt(widget.transactionId);
  }

  Future<void> _downloadPdf() async {
    try {
      final String targetFileName = "Receipt_${widget.transactionOrderId}.pdf";

      final File generatedPdfFile =
          await FlutterHtmlToPdf.convertFromHtmlContent(
            content: _htmlContent,
            configuration: PrintPdfConfiguration(
              targetDirectory: Constant.savePath,
              targetName: targetFileName,
            ),
          );

      await FilePicker.saveFile(
        fileName: targetFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: generatedPdfFile.readAsBytesSync(),
      );
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      if (mounted) {
        HelperUtils.showSnackBarMessage(context, 'errorDownloadingReceipt');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentReceiptCubit, PaymentReceiptState>(
      listener: (context, state) {
        if (state is PaymentReceiptSuccess) {
          _htmlContent = state.htmlContent;
          _controller.loadHtmlString(_htmlContent);
        }
      },
      child: BlocBuilder<PaymentReceiptCubit, PaymentReceiptState>(
        builder: (context, state) {
          return AppScaffold(
            appBar: AppBar(
              title: Text("paymentReceipt".translate(context)),
              actions: [
                if (state is PaymentReceiptSuccess)
                  IconButton(
                    icon: const Icon(AppIcons.downloadSimple),
                    onPressed: _downloadPdf,
                  ),
              ],
            ),
            body: switch (state) {
                PaymentReceiptSuccess() => WebViewWidget(
                  controller: _controller,
                ),
                PaymentReceiptFailure() => QErrorWidget(error: state.error),
                _ => Center(child: LoadingIndicator()),
              },
          );
        },
      ),
    );
  }
}
