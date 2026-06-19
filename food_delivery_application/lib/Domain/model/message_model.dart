import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String sendId;
  final String recieveId;
  final String message;
  final DateTime sentTime;
  bool isRead; // Add isRead field

  MessageModel({
    required this.message,
    required this.recieveId,
    required this.sendId,
    required this.sentTime,
    this.isRead = false, // Default to false for new messages
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      message: json['message'],
      recieveId: json['recieveId'],
      sendId: json['sendId'],
      sentTime: (json['sentTime'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sendId': sendId,
      'recieveId': recieveId,
      'message': message,
      'sentTime': sentTime,
      'isRead': isRead,
    };
  }
}
