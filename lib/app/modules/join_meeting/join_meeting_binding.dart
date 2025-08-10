import 'package:get/get.dart';
import 'join_meeting_controller.dart';

class JoinMeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinMeetingController>(
      () => JoinMeetingController(),
    );
  }
}
