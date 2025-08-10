import 'package:get/get.dart';
import 'create_meeting_controller.dart';

class CreateMeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateMeetingController>(
      () => CreateMeetingController(),
    );
  }
}
