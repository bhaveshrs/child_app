import 'dart:io';

import 'package:child_app/connection_controller.dart';
import 'package:child_app/widgets/viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class ViewerScreen extends StatefulWidget {
  final String url;
  final String type;

  const ViewerScreen({
    required this.url,
    required this.type,
    super.key,
  });

  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final ConnectionController controller =
      Get.find<ConnectionController>(); 

  VideoPlayerController? _videoController;
  String? localFilePath;
  bool isLoading = true;
  double progress = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.prepareFile(widget.url).then((_) {
      if (widget.type == "video" && controller.localFilePath.value != null) {
        print("_videoController----->>>>>>${_videoController == null}");
        if (_videoController != null) {
          _videoController!.dispose();
        }
        _videoController = VideoPlayerController.file(
          File(controller.localFilePath.value!),
        )..initialize().then((_) {
            setState(() {}); 
            _videoController?.play();
          });
      }
    });
     });
    super.initState();

  }

  @override
  void dispose() {
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _videoController?.dispose();
    _videoController = null;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.type.toUpperCase()} Viewer'),
        ),
        body: Obx(() {
          if (controller.isFileLoading.value) {
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    value: controller.downloadProgress.value),
                Text(
                    "downloading.. ${(controller.downloadProgress.value * 100).toInt().toString()}")
              ],
            ));
          } else if (controller.localFilePath.value == null) {
            return const Center(child: Text("Error loading file"));
          } else {
            return ViewerWidget(
              localFilePath: controller.localFilePath.value,
              type: widget.type,
              videoController: _videoController,
            );
          }
        }));
  }



}
