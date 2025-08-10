import 'package:agora_meeting_room/app/widgets/custom_permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService {
  Future<bool> requestPermission({
    required String title,
    required String description,
    required Permission permission,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog();
      return false;
    }

    final bool? result = await Get.dialog<bool>(
      CustomPermissionDialog(
        title: title,
        description: description,
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      final newStatus = await permission.request();
      if (newStatus.isGranted) {
        return true;
      }
      if (newStatus.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      }
      return false;
    }
    return false;
  }

  void _showOpenSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'This permission is permanently denied. Please open settings to enable it.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Get.back();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> requestMicrophone() async {
    return requestPermission(
      title: 'Microphone Permission',
      description: 'This app needs microphone access to let you talk in the meeting.',
      permission: Permission.microphone,
    );
  }

  Future<bool> requestCamera() async {
    return requestPermission(
      title: 'Camera Permission',
      description: 'This app needs camera access to let you share your video in the meeting.',
      permission: Permission.camera,
    );
  }

  Future<bool> requestStorage() async {
    return requestPermission(
      title: 'Storage Permission',
      description: 'This app needs storage access to save recordings or other files.',
      permission: Permission.storage,
    );
  }
}
