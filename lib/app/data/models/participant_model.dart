import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantModel {
  final String userId;
  final String name;
  final int agoraUid;

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.agoraUid,
  });

  factory ParticipantModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParticipantModel(
      userId: doc.id,
      name: data['name'] ?? '',
      agoraUid: data['agoraUid'] ?? 0,
    );
  }
}
