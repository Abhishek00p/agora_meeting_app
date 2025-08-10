import 'package:agora_meeting_room/app/data/models/meeting_model.dart';
import 'package:agora_meeting_room/app/data/services/firestore_service.dart';
import 'package:agora_meeting_room/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JoinMeetingController extends GetxController {
  final meetingIdController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void onClose() {
    meetingIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> joinMeeting() async {
    if (meetingIdController.text.isEmpty) {
      Get.snackbar('Error', 'Meeting ID is required.');
      return;
    }

    isLoading.value = true;
    try {
      final meeting = await _firestoreService.getMeeting(meetingIdController.text.trim());

      if (meeting == null) {
        throw Exception('Meeting not found.');
      }

      if (meeting.password != null && meeting.password != passwordController.text) {
        throw Exception('Invalid password.');
      }

      if (meeting.status == MeetingStatus.ended) {
        throw Exception('This meeting has already ended.');
      }

      // Navigate to the meeting room
      Get.toNamed(Routes.meetingRoom, arguments: meeting);


    } catch (e) {
      Get.snackbar('Error', 'Failed to join meeting: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
