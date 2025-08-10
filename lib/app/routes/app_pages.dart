import 'package:get/get.dart';
import '../modules/create_meeting/create_meeting_binding.dart';
import '../modules/create_meeting/create_meeting_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/join_meeting/join_meeting_binding.dart';
import '../modules/join_meeting/join_meeting_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/member_management/member_management_binding.dart';
import '../modules/member_management/member_management_view.dart';
import '../modules/meeting_room/meeting_room_binding.dart';
import '../modules/meeting_room/meeting_room_view.dart';
import '../modules/user_management/user_management_binding.dart';
import '../modules/user_management/user_management_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.CREATE_MEETING,
      page: () => const CreateMeetingView(),
      binding: CreateMeetingBinding(),
    ),
    GetPage(
      name: Routes.JOIN_MEETING,
      page: () => const JoinMeetingView(),
      binding: JoinMeetingBinding(),
    ),
    GetPage(
      name: Routes.MEETING_ROOM,
      page: () => const MeetingRoomView(),
      binding: MeetingRoomBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_MEMBERS,
      page: () => const MemberManagementView(),
      binding: MemberManagementBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_USERS,
      page: () => const UserManagementView(),
      binding: UserManagementBinding(),
    ),
  ];
}
