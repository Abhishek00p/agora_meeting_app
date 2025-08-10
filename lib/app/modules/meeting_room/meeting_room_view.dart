import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'meeting_room_controller.dart';

const String tempAgoraAppId = "YOUR_AGORA_APP_ID"; // Placeholder

class MeetingRoomView extends GetView<MeetingRoomController> {
  const MeetingRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(controller.meeting.value?.title ?? 'Meeting Room'),
            Text(controller.elapsedTime.value),
          ],
        )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.participants.isEmpty) {
          return const Center(child: Text("Waiting for others to join..."));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.participants.length,
          itemBuilder: (context, index) {
            final participant = controller.participants.values.elementAt(index);
            return GestureDetector(
              onTap: () {
                if (controller.isHost.value && participant.userId != FirebaseAuth.instance.currentUser?.uid) {
                  controller.showParticipantControls(participant.agoraUid);
                }
              },
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Obx(() {
                    final isMuted = controller.remoteMutedStatus[participant.agoraUid] ?? false;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 40),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(participant.name),
                            if (isMuted) const Icon(Icons.mic_off, size: 16),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Obx(() => Icon(controller.isMuted.value ? Icons.mic_off : Icons.mic)),
              onPressed: controller.toggleMute,
            ),
            IconButton(
              icon: const Icon(Icons.call_end),
              onPressed: controller.leaveMeeting,
              color: Colors.red,
            ),
            IconButton(
              icon: Obx(() => Icon(controller.isSpeakerOn.value ? Icons.volume_up : Icons.volume_down)),
              onPressed: controller.toggleSpeaker,
            ),
          ],
        ),
      ),
    );
  }
}
