import 'package:child_app/viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectFile extends StatelessWidget {
  final List<String> mediaList;
  final String type;
  const SelectFile({super.key, required this.mediaList, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "your selected category have more than one file so select from here which file you want to open",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(
                              ViewerScreen(url: mediaList[index], type: type));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Text(
                              "file name : ${mediaList[index].split('/').last}"),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox();
                    },
                    itemCount: mediaList.length))
          ],
        ),
      ),
    );
  }
}
