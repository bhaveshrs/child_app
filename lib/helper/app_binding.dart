
import 'package:child_app/connection_controller.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put<ConnectionController>(ConnectionController());
      Get.lazyPut<ConnectionController>(() => ConnectionController());

   
  }
}
