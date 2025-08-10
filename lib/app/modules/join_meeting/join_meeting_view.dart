import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'join_meeting_controller.dart';

class JoinMeetingView extends GetView<JoinMeetingController> {
  const JoinMeetingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.meetingIdController,
              decoration: const InputDecoration(labelText: 'Meeting ID'),
            ),
            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(labelText: 'Password (Optional)'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.joinMeeting,
              child: const Text('Join Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}
