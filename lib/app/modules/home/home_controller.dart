import 'package:agora_meeting_room/app/data/models/user_model.dart';
import 'package:agora_meeting_room/app/data/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final user = Rx<UserModel?>(null);

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    isLoading.value = true;
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not logged in.');
      }
      final userModel = await _firestoreService.getUser(firebaseUser.uid);
      if (userModel == null) {
        throw Exception('User data not found in Firestore.');
      }
      user.value = userModel;
    } catch (e) {
      Get.snackbar('Error', 'Could not load user data: ${e.toString()}');
      // Potentially log out user here
    } finally {
      isLoading.value = false;
    }
  }
}
