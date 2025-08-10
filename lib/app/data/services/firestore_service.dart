import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton setup
  FirestoreService._();
  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;

  // User methods
  Future<void> addUser(UserModel user) {
    return _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (doc.exists) {
      return UserModel.fromDocument(doc);
    }
    return null;
  }

  // Meeting methods
  Future<DocumentReference> createMeeting(MeetingModel meeting) {
    return _db.collection('meetings').add(meeting.toJson());
  }

  Future<MeetingModel?> getMeeting(String id) async {
    final doc = await _db.collection('meetings').doc(id).get();
    if (doc.exists) {
      return MeetingModel.fromDocument(doc);
    }
    return null;
  }

  Future<void> updateMeetingStatus(String meetingId, {
    MeetingStatus? status,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final data = <String, dynamic>{};
    if (status != null) data['status'] = status.toString();
    if (startTime != null) data['actualStartTime'] = Timestamp.fromDate(startTime);
    if (endTime != null) data['actualEndTime'] = Timestamp.fromDate(endTime);

    return _db.collection('meetings').doc(meetingId).update(data);
  }

  Future<void> addParticipant(String meetingId, String userId, String userName, int agoraUid) {
    return _db
        .collection('meetings')
        .doc(meetingId)
        .collection('participants')
        .doc(userId)
        .set({
          'name': userName,
          'agoraUid': agoraUid,
          'joinTime': FieldValue.serverTimestamp()
        });
  }

  Future<void> removeParticipant(String meetingId, String userId) {
    return _db
        .collection('meetings')
        .doc(meetingId)
        .collection('participants')
        .doc(userId)
        .delete();
  }

  Stream<QuerySnapshot> getParticipants(String meetingId) {
    return _db
        .collection('meetings')
        .doc(meetingId)
        .collection('participants')
        .snapshots();
  }
}
