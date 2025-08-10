import 'package:agora_meeting_room/app/data/models/meeting_model.dart';
import 'package:agora_meeting_room/app/data/services/firestore_service.dart';
import 'package:agora_meeting_room/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMeetingController extends GetxController {
  final titleController = TextEditingController();
  final passwordController = TextEditingController();
  final maxParticipantsController = TextEditingController();
  final requiresApproval = false.obs;

  final FirestoreService _firestoreService = FirestoreService();
  final isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    passwordController.dispose();
    maxParticipantsController.dispose();
    super.onClose();
  }

  Future<void> createMeeting() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Title is required.');
      return;
    }

    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // In a real app, we would get the user model from our own user service
      // to get the full name and member code. For now, using placeholder data.
      final newMeeting = MeetingModel(
        id: '', // Firestore will generate this
        title: titleController.text,
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
        hostName: user.displayName ?? 'Host',
        hostId: user.uid,
        maxParticipants: int.tryParse(maxParticipantsController.text) ?? 50,
        memberCode: 'placeholder-member-code', // Placeholder
        status: MeetingStatus.upcoming,
        totalUniqueParticipants: 0,
        requiresApproval: requiresApproval.value,
      );

      final docRef = await _firestoreService.createMeeting(newMeeting);
      final newMeetingDoc = await docRef.get();
      final createdMeeting = MeetingModel.fromDocument(newMeetingDoc);

      Get.offAndToNamed(Routes.MEETING_ROOM, arguments: createdMeeting);

    } catch (e) {
      Get.snackbar('Error', 'Failed to create meeting: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
