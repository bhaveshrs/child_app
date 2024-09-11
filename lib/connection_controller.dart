import 'dart:io';

import 'package:child_app/helper/app_helper.dart';
import 'package:child_app/models/data_model.dart';
import 'package:child_app/select_file_screen.dart';
import 'package:child_app/viewer_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectionController extends GetxController {
  final _flutterP2pConnectionPlugin = FlutterP2pConnection();
  RxList<DiscoveredPeers> peers = <DiscoveredPeers>[].obs;
  Rx<WifiP2PInfo?> wifiP2PInfo = Rx<WifiP2PInfo?>(null);
  Rx<bool> isDiscoveryLoading = false.obs;
  Rx<bool> allPermissionGranted = false.obs;
  Rx<bool> isLoading = false.obs;
  Rx<bool> isFileLoading = false.obs;
  Rx<bool> hasError = false.obs;
  Rx<bool> wifiEnable = false.obs;
  Rx<bool> locationEnable = false.obs;
  Rx<bool> isSocketConnected = false.obs;
  Rx<MediaData> mediaData = MediaData().obs;
  Rx<File?> downloadedFile = Rx<File?>(null);
  Rx<String?> localFilePath = Rx<String?>(null);
  Rx<double> downloadProgress = 0.0.obs;
  final Dio dio = Dio();

  @override
  void onInit() {
    super.onInit();
    p2pInit();
    askAllPermissions();
    fetchData();
  }

  void p2pInit() async {
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();

    _flutterP2pConnectionPlugin.streamWifiP2PInfo().listen((event) async {
      wifiP2PInfo.value = event;
      print("----------<<<<<<<<<<<>>>>>>>>>>>>>>");
      print("----------<<<<<<<<<<<${event.isConnected}>>>>>>>>>>>>>>");

      if (wifiP2PInfo.value?.isConnected ?? false) {
        if (!isSocketConnected.value) {
          await waitForSocketSetupAndConnect();
        } else {
          isSocketConnected.value = false;
        }
      }

      debugPrint(
          "connected: ${wifiP2PInfo.value?.isConnected}, isGroupOwner: ${wifiP2PInfo.value?.isGroupOwner}, groupFormed: ${wifiP2PInfo.value?.groupFormed}, groupOwnerAddress: ${wifiP2PInfo.value?.groupOwnerAddress}, clients: ${wifiP2PInfo.value?.clients}");
    });

    _flutterP2pConnectionPlugin.streamPeers().listen((event) {
      print("i am callled");
      // print(event[0].deviceAddress);
      peers.assignAll(event); 
      print(peers);
    });
  }

  Future<void> waitForSocketSetupAndConnect() async {
    const retryDelay = Duration(seconds: 2);
    int retryCount = 5;

    for (int i = 0; i < retryCount; i++) {
      if (wifiP2PInfo.value != null &&
          wifiP2PInfo.value!.groupFormed &&
          isSocketConnected.value == false) {
        try {
          print("Trying to connect to socket, attempt ${i + 1}");
          await connectToSocket();

          break;
        } catch (e) {
          print("Socket connection failed: $e");
        }
      }
      await Future.delayed(retryDelay);
    }
    if (!isSocketConnected.value) {
      print("Failed to connect to the socket after $retryCount attempts.");
    }
  }

  Future<void> p2pRemoveGroup() async {
    bool? removed = await _flutterP2pConnectionPlugin.removeGroup();
    if (removed) {
      isSocketConnected.value = false;
      AppHelper.showToastMessage("wifi group closed");
    } else {
      AppHelper.showToastMessage("something went wrong");
    }
  }

  void p2pDiscover() async {
    if (await askAllPermissions()) {
      try {
        isDiscoveryLoading.value = true;
        await _flutterP2pConnectionPlugin.discover();
        AppHelper.showToastMessage("discovering started");
      } catch (e) {
        print("e-------->>>>>>>>$e");
        AppHelper.showToastMessage("can't able to discover");
      }
    }
  }

  void p2pStopDiscovery() async {
    try {
      await _flutterP2pConnectionPlugin.stopDiscovery();
      isDiscoveryLoading.value = false;
      AppHelper.showToastMessage("discovering stopped");
    } catch (e) {
      AppHelper.showToastMessage("can't able to discover");
    }
  }

  void p2pConnect(int index) async {
    bool? bo =
        await _flutterP2pConnectionPlugin.connect(peers[index].deviceAddress);

    if (bo) {
      isDiscoveryLoading.value = false;
      peers.value = [];
    }
    AppHelper.showToastMessage("connected :$bo");
    if (bo) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future connectToSocket() async {
    if (wifiP2PInfo.value != null &&
        wifiP2PInfo.value?.groupOwnerAddress != null &&
        wifiP2PInfo.value!.groupOwnerAddress.isNotEmpty) {
      await _flutterP2pConnectionPlugin.connectToSocket(
        groupOwnerAddress: wifiP2PInfo.value!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (address) {
          isSocketConnected.value = true;
          print("Successfully connected to socket.");
          AppHelper.showToastMessage("connected to socket: $address");
        },
        transferUpdate: (transfer) {
          if (transfer.completed) {
            AppHelper.showToastMessage(
                "${transfer.failed ? "failed to ${transfer.receiving ? "receive" : "send"}" : transfer.receiving ? "received" : "sent"}: ${transfer.filename}");
          }
          print(
              "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}");
        },
        receiveString: (req) async {
          if (req.toString() == "show images") {
            if (mediaData.value.image.length > 1) {
              Get.to(SelectFile(
                mediaList: mediaData.value.image,
                type: "image",
              ));
            } else if (mediaData.value.image.length == 1) {
              Get.to(ViewerScreen(
                url: mediaData.value.image[0],
                type: "image",
              ));
            }
          } else if (req.toString() == "show video") {
            if (mediaData.value.videos.length > 1) {
              Get.to(SelectFile(
                mediaList: mediaData.value.videos,
                type: "video",
              ));
            } else if (mediaData.value.videos.length == 1) {
              Get.back();
              Get.to(ViewerScreen(
                url: mediaData.value.videos[0],
                type: "video",
              ));
            }
          } else if (req.toString() == "show pdf") {
            print(mediaData.value.brochures);
            if (mediaData.value.brochures.length > 1) {
              Get.to(SelectFile(
                mediaList: mediaData.value.brochures,
                type: "pdf",
              ));
              print(
                  "mediaData.value.brochures.length -->${mediaData.value.brochures.length}");
            } else if (mediaData.value.brochures.length == 1) {
              Get.back();
              print("object");
              Get.to(ViewerScreen(
                url: mediaData.value.brochures[0],
                type: "pdf",
              ));
            }
          }
          AppHelper.showToastMessage(req);
        },
      );
    }
  }

  Future<bool> askAllPermissions() async {
    if (await _requestPermission(Permission.location, "Location")) {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        int androidVersion =
            androidInfo.version.sdkInt; 

      
        if (androidVersion >= 33) {
          if (await _requestPermission(
              Permission.nearbyWifiDevices, "Nearby Wi-Fi Devices")) {
            if (await _requestPermission(Permission.manageExternalStorage,
                    "Manage External Storage") ||
                await _requestPermission(Permission.photos, "Photos") ||
                await _requestPermission(Permission.videos, "Videos")) {
              allPermissionGranted.value =
                  await checkAndEnableServices(wifi: true, location: true);
              return allPermissionGranted.value;
            }
          }
        } else {
          if (await _requestPermission(Permission.storage, "Storage")) {
            allPermissionGranted.value =
                await checkAndEnableServices(wifi: true, location: true);
            return allPermissionGranted.value;
          }
        }
      }
    }

    allPermissionGranted.value = false;
    return false;
  }

  Future<bool> _requestPermission(
      Permission permission, String permissionName) async {
    if (await permission.isGranted) {
      print("$permissionName permission already granted.");
      return true;
    } else {
      PermissionStatus status = await permission.request();
      if (status.isGranted) {
        print("$permissionName permission granted.");
        return true;
      } else if (status.isPermanentlyDenied) {
        AppHelper.showToastMessage(
            "The $permissionName permission is required for the app to function properly. Please go to settings to enable it.");
        return false;
      } else {
        print("$permissionName permission denied.");
        return false;
      }
    }
  }

  Future<bool> checkAndEnableServices({bool? wifi, bool? location}) async {
    if (location ?? false) {
      locationEnable.value =
          await _flutterP2pConnectionPlugin.checkLocationEnabled();
      print("Location is $locationEnable.value.");
      if (!locationEnable.value) {
        await _flutterP2pConnectionPlugin.enableLocationServices();
      }
    }
    if (wifi ?? false) {
      wifiEnable.value = await _flutterP2pConnectionPlugin.checkWifiEnabled();
      print("Wi-Fi is ${wifiEnable.value}.");
      if (!wifiEnable.value) {
        bool wifiSuccess =
            await _flutterP2pConnectionPlugin.enableWifiServices();
        if (!wifiSuccess) return false;
      }
    }

    return locationEnable.value && wifiEnable.value;
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final response = await dio
          .get('https://codnestx.com/wp-content/uploads/2024/08/api.json');

      if (response.statusCode == 200) {
        MediaData apiResponse = MediaData.fromMap(response.data);
        mediaData.value = apiResponse;
        hasError.value = false;
        AppHelper.showToastMessage("data fetched..");
      } else {
        hasError.value = true;
        AppHelper.showToastMessage("Something went wrong!");
      }
    } catch (e, s) {
      print(e);
      print("--------->>>>>>>>$s");
      hasError.value = true;
      AppHelper.showToastMessage("Unexpected error occurred!");
    } finally {
      isLoading.value = false; 
    }
  }

  Future<void> prepareFile(String url) async {
    isFileLoading.value = true; 
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final file = File('${directory.path}/$fileName');
      print("file ------>>>>>>$file");
      print("file ------>>>>>>${file.path}");

      if (await file.exists()) {
        print("file ------>>>>>>existtttt");
        localFilePath.value = file.path;
        downloadedFile.value = file;
        isFileLoading.value = false;
      } else {
        print("file ------>>>>>>download");
        await dio.download(
          url,
          file.path,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              downloadProgress.value = received / total;
            }
            if (downloadProgress.value == 1) {
              downloadProgress.value = 0;
            }
          },
        );

        localFilePath.value = file.path;
        downloadedFile.value = file;
      }
    } catch (e) {
      print("Error downloading file: $e");
      AppHelper.showToastMessage("Error downloading file");
    } finally {
      isFileLoading.value = false; 
    }
  }
}
