import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'member_management_controller.dart';

class MemberManagementView extends GetView<MemberManagementController> {
  const MemberManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Members'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.members.isEmpty) {
          return const Center(child: Text('No members found.'));
        }
        return ListView.builder(
          itemCount: controller.members.length,
          itemBuilder: (context, index) {
            final member = controller.members[index];
            return ListTile(
              title: Text(member.fullName),
              subtitle: Text(member.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.showDeleteConfirmation(member),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddMemberDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
