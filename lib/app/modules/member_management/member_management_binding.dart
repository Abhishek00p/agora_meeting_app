import 'package:get/get.dart';
import 'member_management_controller.dart';

class MemberManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberManagementController>(
      () => MemberManagementController(),
    );
  }
}
