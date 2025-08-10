import 'package:agora_meeting_room/app/data/models/user_model.dart';
import 'package:agora_meeting_room/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Obx(() {
            if (controller.user.value?.role == UserRole.admin) {
              return IconButton(
                icon: const Icon(Icons.people),
                onPressed: () => Get.toNamed(Routes.MANAGE_MEMBERS),
              );
            }
            if (controller.user.value?.role == UserRole.member) {
              return IconButton(
                icon: const Icon(Icons.group_add),
                onPressed: () => Get.toNamed(Routes.MANAGE_USERS),
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! This is the home screen.'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.CREATE_MEETING),
              child: const Text('Host a Meeting'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.JOIN_MEETING),
              child: const Text('Join a Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}
