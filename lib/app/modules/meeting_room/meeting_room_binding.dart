import 'package:get/get.dart';
import 'meeting_room_controller.dart';

class MeetingRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingRoomController>(
      () => MeetingRoomController(),
    );
  }
}
