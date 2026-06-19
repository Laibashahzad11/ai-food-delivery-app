import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Repository/message_repo.dart';
import 'package:food_delivery_app_project/Domain/model/message_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';

class MessageController extends ChangeNotifier {
  final db = MessageDB();
  bool isloading = false;

  List<MessageModel> messages = [];
  Map<String, MessageModel> lastMessages =
      {}; // Map to store last message for each user
  Map<String, String> last = {}; //
  Map<String, bool> isread = {}; //
  Map<String, int> unreadCounts = {}; //
  Map<String, DateTime> lastMessageTime = {}; //

  ScrollController scrollController = ScrollController();
  int chatsize = 0;
  int unreadCount = 0;

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  void updateUnreadCount(String userId, int count) {
    unreadCounts[userId] = count;
    notifyListeners();
  }

  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 1), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage({
    required MessageModel message,
    required String senderId,
    required String recieverId,
    required UserModel user,
  }) async {
    try {
      await db.sendMessage(
          user: user,
          message: message,
          recieverId: recieverId,
          senderId: senderId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getAllMessages(
      {required String recieverId, required String senderId}) async {
    try {
      isloading = true;

      FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('chats')
          .doc(recieverId)
          .collection('messages')
          .orderBy('sentTime', descending: false)
          .snapshots(includeMetadataChanges: true)
          .listen((event) {
        log('hiii');
        // messages = event.docs.map((e) => Message.fromJson(e.data())).toList();
        messages = event.docs.map((e) {
          MessageModel message = MessageModel.fromJson(e.data());
          // Mark the message as read when it'ss fetched

          return message;
        }).toList();

        isloading = false;
        notifyListeners();
        MessageModel lastMessage = messages.last;
        String recievedId = recieverId; // Store receiverId

        // Update last message for this receiver

        lastMessages[recievedId] = lastMessage;
        last[recievedId] = lastMessage.message;

        // isread[recievedId] = lastMessage.isRead;

        // log(isread[recievedId].toString());
        lastMessageTime[recievedId] = lastMessage.sentTime;

        unreadCount = messages
            .where((msg) => !msg.isRead && msg.recieveId == senderId)
            .length;
        log('kaskakmskda${unreadCount.toString()}');

        updateUnreadCount(recieverId, unreadCount);
        // unReadCount[recievedId] = unreadCount;

        // if (messages.isNotEmpty) {
        //   // Determine the last message for this receiver
        //   Message lastMessage = messages.last;
        //   String recievedId = recieverId; // Store receiverId

        //   // Update last message for this receiver

        //   lastMessages[recievedId] = lastMessage;
        //   last[recievedId] = lastMessage.message;
        // } else {
        //   // No messages
        //   String recievedId = recieverId; // Store receiverId

        //   lastMessages[recievedId] = Message(
        //       message: '',
        //       recieveId: '',
        //       sendId: '',
        //       sentTime: DateTime.now(),
        //       isSend: true); // Empty string isf no messages
        // }
        scrollToEnd();

        notifyListeners();
      });

      // log('khaaaa${messages.toString()}');

      return messages;
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow; // You can handle the error as needed in the calling code
    }
  }

  Future<void> markMessagesAsRead({
    required String senderId,
    required String recieverId,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('chats')
        .doc(recieverId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();
    log('length is ${querySnapshot.docs.length.toString()}');
    for (var doc in querySnapshot.docs) {
      if (doc['sendId'] != senderId) {
        log('Updating isRead to true');

        doc.reference.update({'isRead': true});
      }
    }

    await batch.commit();

    // for (var message in messages) {
    //   if (message.sendId == recieverId && message.recieveId == senderId) {
    //     message.isRead = true;
    //   }
    // }

    notifyListeners();
  }

  Future<List<MessageModel>> fetchAllMessages(
      List<String> chatIds, String userId) async {
    // final userId = context.read<AuthController>().appUser!.id;
    List<MessageModel> allMessages = [];

    for (String chatId in chatIds) {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('sentTime', descending: false)
          .get();

      final messages = messagesSnapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();

      allMessages.addAll(messages);
    }

    return allMessages;
  }

  Future<List<MessageModel>> getAllMessagesRest({required String conversationId}) async {
    try {
      isloading = true;
      notifyListeners();
      
      messages = await db.getMessagesRest(conversationId);
      
      isloading = false;
      notifyListeners();
      return messages;
    } catch (e) {
      isloading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<int> chatLength({required String uid}) async {
    try {
      chatsize = await db.chatLength(uid: uid);
      log(chatsize.toString());
      notifyListeners();
      return chatsize;
    } catch (e) {
      rethrow;
    }
  }
}
