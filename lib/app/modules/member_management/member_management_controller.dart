import 'package:agora_meeting_room/app/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberManagementController extends GetxController {
  final isLoading = true.obs;
  final members = <UserModel>[].obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    isLoading.value = true;
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Admin not logged in.');
      }

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.member.toString())
          .where('createdBy', isEqualTo: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .get();

      members.value = snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch members: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showAddMemberDialog() {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Member'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
                ),
                // Other fields like subscription plan can be added here
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back(); // Close dialog
                addMember(
                  fullName: fullNameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  String _generateMemberCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> addMember({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final admin = _auth.currentUser;
      if (admin == null) throw Exception('Not authenticated as Admin.');

      // Create a temporary Firebase app to create the user
      final tempAppName = 'temp-member-creation-${DateTime.now().millisecondsSinceEpoch}';
      final tempApp = await Firebase.initializeApp(
        name: tempAppName,
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newMember = userCredential.user;
      if (newMember == null) throw Exception('Failed to create member account.');

      // Now save the user data to Firestore
      final userModel = UserModel(
        id: newMember.uid,
        fullName: fullName,
        email: email,
        role: UserRole.member,
        memberCode: _generateMemberCode(8),
        createdBy: admin.uid,
        planExpiryDate: DateTime.now().add(const Duration(days: 30)), // Example expiry
      );

      await _firestore.collection('users').doc(newMember.uid).set(userModel.toJson());

      // Clean up the temporary app
      await tempApp.delete();

      Get.snackbar('Success', 'Member added successfully!');
      fetchMembers(); // Refresh the list
    } catch (e) {
      Get.snackbar('Error', 'Failed to add member: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showDeleteConfirmation(UserModel member) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${member.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteMember(member.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteMember(String memberId) async {
    isLoading.value = true;
    try {
      await _firestore.collection('users').doc(memberId).update({'isActive': false});
      Get.snackbar('Success', 'Member deleted successfully.');
      fetchMembers(); // Refresh list
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete member: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
