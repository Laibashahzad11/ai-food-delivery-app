import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_project/Data/api_config.dart';
import 'package:food_delivery_app_project/Domain/model/message_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:http/http.dart' as http;

class MessageDB {
  Future<void> sendMessage(
      {required MessageModel message,
      required String senderId,
      required String recieverId,
      required UserModel user}) async {
    try {
      log(message.toJson().toString());
      
      // Real REST API Call
      final response = await http.post(
        Uri.parse(ApiConfig.sendMessageEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...message.toJson(),
          'sender_id': senderId,
          'receiver_id': recieverId,
          'user': user.toJson(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        log('Failed to send message via REST: ${response.statusCode}');
      }

      // Keep Firestore as fallback/parallel for now if needed, 
      // but the requirement is to use real database.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('chats')
          .doc(recieverId)
          .collection('messages')
          .add(message.toJson());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(recieverId)
          .collection('chats')
          .doc(senderId)
          .collection('messages')
          .add(message.toJson());

      FirebaseFirestore.instance
          .collection('users')
          .doc(recieverId)
          .collection('chats')
          .doc(senderId)
          .set(user.toJson());

    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessagesRest(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getMessagesEndpoint(conversationId)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      log('Error fetching messages via REST: $e');
      return [];
    }
  }

  Future<int> chatLength({required String uid}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<DocumentSnapshot>> getChats({required String userId}) {
    try {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chats')
          .snapshots()
          .map((snapshot) => snapshot.docs);
      return doc;
    } catch (e) {
      // Handle any errors that occur during chat retrieval
      rethrow;
    }
  }
}
