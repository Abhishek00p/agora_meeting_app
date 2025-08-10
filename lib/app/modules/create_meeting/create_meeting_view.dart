import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_meeting_controller.dart';

class CreateMeetingView extends GetView<CreateMeetingController> {
  const CreateMeetingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(labelText: 'Password (Optional)'),
            ),
            TextField(
              controller: controller.maxParticipantsController,
              decoration: const InputDecoration(labelText: 'Max Participants'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                const Text('Requires Approval to Speak?'),
                Obx(() => Switch(
                      value: controller.requiresApproval.value,
                      onChanged: (val) => controller.requiresApproval.value = val,
                    )),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.createMeeting,
              child: const Text('Create Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}
