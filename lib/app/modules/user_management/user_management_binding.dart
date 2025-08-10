import 'package:get/get.dart';
import 'user_management_controller.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserManagementController>(
      () => UserManagementController(),
    );
  }
}
