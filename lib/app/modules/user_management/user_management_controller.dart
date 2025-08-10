import 'package:agora_meeting_room/app/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementController extends GetxController {
  final isLoading = true.obs;
  final users = <UserModel>[].obs;
  UserModel? currentMember;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Member not logged in.');

      // Fetch the current member's data to get their memberCode and expiry
      final memberDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!memberDoc.exists) throw Exception('Current member data not found.');
      currentMember = UserModel.fromDocument(memberDoc);

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.user.toString())
          .where('createdBy', isEqualTo: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .get();

      users.value = snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(AlertDialog(
      title: const Text('Add New User'),
      content: Form(
        key: formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back();
                addUser(
                  fullName: fullNameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
            child: const Text('Add User')),
      ],
    ));
  }

  Future<void> addUser({required String fullName, required String email, required String password}) async {
    isLoading.value = true;
    try {
      if (currentMember == null) throw Exception('Current member details not available.');

      final tempAppName = 'temp-user-creation-${DateTime.now().millisecondsSinceEpoch}';
      final tempApp = await Firebase.initializeApp(name: tempAppName, options: Firebase.app().options);
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final userCredential = await tempAuth.createUserWithEmailAndPassword(email: email, password: password);
      final newUser = userCredential.user;
      if (newUser == null) throw Exception('Failed to create user account.');

      final userModel = UserModel(
        id: newUser.uid,
        name: fullName,
        email: email,
        role: UserRole.user,
        fullName: fullName,
        memberCode: currentMember!.memberCode, // Use member's code
        createdBy: currentMember!.id,
        planExpiryDate: currentMember!.planExpiryDate, // Use member's expiry
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(newUser.uid).set(userModel.toJson());
      await tempApp.delete();

      Get.snackbar('Success', 'User added successfully!');
      fetchUsers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add user: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void showDeleteConfirmation(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(String userId) async {
    isLoading.value = true;
    try {
      await _firestore.collection('users').doc(userId).update({'isActive': false});
      Get.snackbar('Success', 'User deleted successfully.');
      fetchUsers(); // Refresh list
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
