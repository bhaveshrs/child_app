import 'package:child_app/connection_controller.dart';
import 'package:child_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'helper/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectionController connectionController =
      Get.find<ConnectionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              children: [
                if (connectionController.isDiscoveryLoading.value) ...[
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi,
                          color: AppColors.mainColor,
                          size: 30,
                        ),
                        const Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: LinearProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              connectionController.p2pStopDiscovery();
                            },
                            child: const Text("Stop"))
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  PrimaryButton(
                    onPressed: () {
                      connectionController.p2pDiscover();
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.mainColor,
                    title: "Start Discovery",
                    isLoading: false,
                  ),
                ],
                const SizedBox(
                  height: 10,
                ),
                if (connectionController.wifiP2PInfo.value?.isConnected ??
                    false) ...[
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Connected to:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[800],
                                ),
                              ),
                              Text(
                                (connectionController
                                        .wifiP2PInfo.value?.groupOwnerAddress)
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  connectionController.p2pRemoveGroup();
                                },
                                child: const Text(
                                  "Disconnect",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              ),
                              if (connectionController
                                      .isSocketConnected.value ==
                                  false) ...[
                                GestureDetector(
                                  onTap: () {
                                    connectionController.connectToSocket();
                                  },
                                  child: const Text(
                                    "enable Msg Transfer",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ]),

                        // butt(
                        //   onPressed: () {
                        //     // connectionController.disconnectDevice();
                        //   },
                        //   // icon: const Icon(
                        //   //   Icons.close,
                        //   //   color: Colors.red,
                        //   //   size: 30,
                        //   // ),
                        // ),
                      ],
                    ),
                  ),
                ],

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          connectionController.checkAndEnableServices(
                              location: true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: connectionController.locationEnable.value
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5)),
                          child: Text(
                              "Location :${connectionController.locationEnable.value ? "Enable" : "Disable"}"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          connectionController.checkAndEnableServices(
                              wifi: true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: connectionController.wifiEnable.value
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5)),
                          child: Text(
                              "wifi :${connectionController.wifiEnable.value ? "Enable" : "Disable"}"),
                        ),
                      ),
                    ),
                  ],
                ),
                // Container()
                if (!(connectionController.wifiP2PInfo.value?.isConnected ??
                    false))
                  Flexible(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      connectionController
                                          .peers[index].deviceName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      connectionController.p2pConnect(index);
                                    },
                                    child: const Text(
                                      "Connect",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: connectionController.peers.length),
                  )
              ],
            ),
          ),
        );
      }),
    );
  }
}
