import 'dart:async';

import 'package:agora_meeting_room/app/data/models/meeting_model.dart';
import 'package:agora_meeting_room/app/data/models/participant_model.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agora_meeting_room/app/data/services/firestore_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

const String tempAgoraAppId = "a28285a83705488c801c40212f80695b"; // Placeholder - MUST BE REPLACED
const String tempToken = "007eJxTYPCW/p3P+t1X+Xz4vV8tS0aH5G9Y8fJ39dK0S4W/BwUW+woMhmlJSSZpZonGZimmSSmmSSZpySZpaYlGZiamSUZpXqL3lIZARgZl+QdZGBkZIBDEZ2LIyElNzs/jZDAwAAA+iR9p";       // Placeholder - MUST BE REPLACED

class MeetingRoomController extends GetxController {
  final meeting = Rx<MeetingModel?>(null);
  final FirestoreService _firestoreService = FirestoreService();
  RtcEngine? _engine;

  final isLoading = true.obs;
  final isHost = false.obs;
  final isMuted = false.obs;
  final isSpeakerOn = true.obs;
  final remoteUids = <int>{}.obs;
  final remoteMutedStatus = <int, bool>{}.obs;
  final participants = <int, ParticipantModel>{}.obs;
  StreamSubscription? _participantsSubscription;
  Timer? _timer;
  final elapsedTime = "00:00".obs;

  @override
  void onInit() {
    super.onInit();
    meeting.value = Get.arguments as MeetingModel?;
    if (meeting.value != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      isHost.value = currentUser?.uid == meeting.value!.hostId;
      _initAgora();
    } else {
      Get.snackbar('Error', 'Could not load meeting details.');
      Get.back();
    }
  }

  Future<void> _initAgora() async {
    await [Permission.microphone].request();

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: tempAgoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _addAgoraEventHandlers();

      await _engine!.enableAudio();
      await _engine!.joinChannel(
        token: tempToken,
        channelId: meeting.value!.id,
        options: const ChannelMediaOptions(),
        uid: 0, // 0 lets Agora assign a UID
      );

      _listenToParticipants();

    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize meeting: ${e.toString()}');
      leaveMeeting();
    } finally {
      isLoading.value = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final seconds = timer.tick;
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      elapsedTime.value =
          '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    });
  }

  void _addAgoraEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onLocalUserRegistered: (uid, userAccount) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            _firestoreService.addParticipant(
              meeting.value!.id,
              currentUser.uid,
              currentUser.displayName ?? 'User',
              uid,
            );
          }
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          _startTimer();
          if (isHost.value) {
            _firestoreService.updateMeetingStatus(
              meeting.value!.id,
              status: MeetingStatus.ongoing,
              startTime: DateTime.now(),
            );
          } else {
            _engine?.muteLocalAudioStream(true);
            isMuted.value = true;
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          remoteUids.add(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          remoteUids.remove(remoteUid);
        },
        onError: (ErrorCodeType err, String msg) {
          Get.snackbar('Agora Error', 'Code: $err, Message: $msg');
        },
      ),
    );
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    _engine!.muteLocalAudioStream(isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    _engine!.setEnableSpeakerphone(isSpeakerOn.value);
  }

  Future<void> leaveMeeting() async {
    isLoading.value = true;
    try {
      if (isHost.value) {
        await _firestoreService.updateMeetingStatus(
          meeting.value!.id,
          status: MeetingStatus.ended,
          endTime: DateTime.now(),
        );
      }
      _timer?.cancel();
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
    } finally {
      _engine = null;
      Get.back();
    }
  }

  @override
  void onClose() {
    leaveMeeting();
    super.onClose();
  }

  void showParticipantControls(int uid) {
    final isRemoteMuted = remoteMutedStatus[uid] ?? false;
    Get.dialog(
      AlertDialog(
        title: Text('Controls for User $uid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                toggleRemoteMute(uid);
              },
              child: Text(isRemoteMuted ? 'Unmute User' : 'Mute User'),
            ),
            // TODO: Add Kick and Promote buttons here
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
        ],
      ),
    );
  }

  void toggleRemoteMute(int uid) {
    final newMutedState = !(remoteMutedStatus[uid] ?? false);
    _engine?.muteRemoteAudioStream(uid: uid, mute: newMutedState);
    remoteMutedStatus[uid] = newMutedState;
  }

  void _listenToParticipants() {
    _participantsSubscription = _firestoreService
        .getParticipants(meeting.value!.id)
        .listen((snapshot) {
      final newParticipants = <int, ParticipantModel>{};
      for (final doc in snapshot.docs) {
        final participant = ParticipantModel.fromDocument(doc);
        newParticipants[participant.agoraUid] = participant;
      }
      participants.value = newParticipants;
    });
  }

  Future<void> leaveMeeting() async {
    isLoading.value = true;
    try {
      _participantsSubscription?.cancel();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _firestoreService.removeParticipant(meeting.value!.id, currentUser.uid);
      }
      if (isHost.value) {
        await _firestoreService.updateMeetingStatus(
          meeting.value!.id,
          status: MeetingStatus.ended,
          endTime: DateTime.now(),
        );
      }
      _timer?.cancel();
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
    } finally {
      _engine = null;
      Get.back();
    }
  }
}
