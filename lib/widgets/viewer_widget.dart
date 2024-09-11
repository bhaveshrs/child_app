import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ViewerWidget extends StatelessWidget {
  final VideoPlayerController? videoController;
  final String? localFilePath;
  final String? type;
  const ViewerWidget(
      {super.key, this.videoController, this.localFilePath, this.type});

  @override
  Widget build(BuildContext context) {
    print(localFilePath);
    if (localFilePath == null) {
      return const Center(child: Text("Failed to load file."));
    }

    switch (type) {
      case 'image':
        return PhotoView(
          imageProvider: FileImage(File(localFilePath!)),
        );
      case 'pdf':
        return SizedBox(
          height: Get.size.height - 100,
          width: Get.size.width - 20,
          child: PdfViewer.openFile(localFilePath ?? ""),
        );
      case 'video':
        if (videoController == null || !videoController!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: AspectRatio(
            aspectRatio: videoController!.value.aspectRatio,
            child: VideoPlayer(videoController!),
          ),
        );
      default:
        return const Center(child: Text("Unsupported content type"));
    }
  }
}
