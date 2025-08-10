import 'package:cloud_firestore/cloud_firestore.dart';

enum MeetingStatus { upcoming, ongoing, ended }

class MeetingModel {
  final String id;
  final String title;
  final String? password;
  final String hostName;
  final String hostId;
  final int maxParticipants;
  final String memberCode;
  final DateTime? scheduleStartTime;
  final DateTime? scheduleEndTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final int totalUniqueParticipants;
  final MeetingStatus status;
  final bool requiresApproval;

  MeetingModel({
    required this.id,
    required this.title,
    this.password,
    required this.hostName,
    required this.hostId,
    required this.maxParticipants,
    required this.memberCode,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.totalUniqueParticipants,
    required this.status,
    this.requiresApproval = false,
  });

  factory MeetingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeetingModel(
      id: doc.id,
      title: data['title'] ?? '',
      password: data['password'],
      hostName: data['hostName'] ?? '',
      hostId: data['hostId'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 0,
      memberCode: data['memberCode'] ?? '',
      scheduleStartTime: data['scheduleStartTime'] != null
          ? (data['scheduleStartTime'] as Timestamp).toDate()
          : null,
      scheduleEndTime: data['scheduleEndTime'] != null
          ? (data['scheduleEndTime'] as Timestamp).toDate()
          : null,
      actualStartTime: data['actualStartTime'] != null
          ? (data['actualStartTime'] as Timestamp).toDate()
          : null,
      actualEndTime: data['actualEndTime'] != null
          ? (data['actualEndTime'] as Timestamp).toDate()
          : null,
      totalUniqueParticipants: data['totalUniqueParticipants'] ?? 0,
      status: MeetingStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => MeetingStatus.ended,
      ),
      requiresApproval: data['requiresApproval'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'password': password,
      'hostName': hostName,
      'hostId': hostId,
      'maxParticipants': maxParticipants,
      'memberCode': memberCode,
      'scheduleStartTime': scheduleStartTime != null
          ? Timestamp.fromDate(scheduleStartTime!)
          : null,
      'scheduleEndTime': scheduleEndTime != null
          ? Timestamp.fromDate(scheduleEndTime!)
          : null,
      'actualStartTime': actualStartTime != null
          ? Timestamp.fromDate(actualStartTime!)
          : null,
      'actualEndTime': actualEndTime != null
          ? Timestamp.fromDate(actualEndTime!)
          : null,
      'totalUniqueParticipants': totalUniqueParticipants,
      'status': status.toString(),
      'requiresApproval': requiresApproval,
    };
  }
}
