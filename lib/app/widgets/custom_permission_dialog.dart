import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_meeting_room/app/utils/app_theme.dart';

class CustomPermissionDialog extends StatelessWidget {
  final String title;
  final String description;

  const CustomPermissionDialog({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(title, style: Get.textTheme.titleLarge),
      content: Text(description, style: Get.textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Ask Later'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Allow'),
        ),
      ],
    );
  }
}
