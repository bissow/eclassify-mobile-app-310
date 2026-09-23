import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({required this.url, super.key});

  final String url;

  @override
  _PDFViewerState createState() => _PDFViewerState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => PdfViewer(url: routeSettings.arguments as String),
    );
  }
}

class _PDFViewerState extends State<PdfViewer> {
  late File Pfile;
  bool isLoading = false;

  Future<void> loadNetwork() async {
    setState(() {
      isLoading = true;
    });
    var url = widget.url;

    try {
      Response response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      final filename = path.basename(
        url,
      ); // Use path.basename instead of basename
      final dir = await getApplicationDocumentsDirectory();
      var file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        Pfile = file;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    loadNetwork();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(backgroundColor: context.colorScheme.secondary),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Center(child: PDFView(filePath: Pfile.path)),
            ),
    );
  }
}
