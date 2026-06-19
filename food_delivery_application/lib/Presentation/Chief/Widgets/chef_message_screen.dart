import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
import 'package:food_delivery_app_project/Domain/model/message_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/message_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class ChefMessageScreen extends StatefulWidget {
  const ChefMessageScreen({
    super.key,
    required this.uid,
    required this.user,
  });
  final UserModel user;
  final String uid;

  @override
  State<ChefMessageScreen> createState() => _ChefMessageScreenState();
}

class _ChefMessageScreenState extends State<ChefMessageScreen> {
  bool isChatScreen = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isChatScreen = true;
    getMessages();
    listenForMessages();

    messageController.addListener(() {
      setState(() {
        // Update the state based on whether the messageController is empty or not
        isMessageEmpty = messageController.text.isEmpty;
      });
    });
    focusNode.addListener(() {
      setState(() {
        isKeyboardVisible = focusNode.hasFocus;
        log(isKeyboardVisible.toString());
      });
    });
  }

  Future<void> getMessages() async {
    // Determine conversation ID (common pattern: smallerId_largerId)
    final ids = [widget.uid, widget.user.id]..sort();
    final conversationId = ids.join('_');

    await context
        .read<MessageController>()
        .getAllMessagesRest(conversationId: conversationId);
    markMessagesAsRead();
  }

  Future<void> markMessagesAsRead() async {
    log('message');
    await context.read<MessageController>().markMessagesAsRead(
          senderId: widget.uid,
          recieverId: widget.user.id,
        );
  }

  Future<void> listenForMessages() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .collection('chats')
        .doc(widget.uid)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('recieveId', isEqualTo: widget.uid)
        .snapshots()
        .listen((snapshot) {
      if (isChatScreen == true) {
        context.read<MessageController>().scrollToEnd();
        for (var doc in snapshot.docs) {
          log('here');
          // markMessagesAsRead();

          if (doc['sendId'] != widget.uid) {
            log('Updating isRead to true');

            doc.reference.update({'isRead': true});
          }
        }
      }
      // // setState(
      // //   () {
      // //     isChatScreen = false;
      // //   },
      // );
      // log('chat screen is$isChatScreen');
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('chats')
        .doc(widget.user.id)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('recieveId', isEqualTo: widget.uid)
        .snapshots()
        .listen((snapshot) {
      if (isChatScreen == true) {
        for (var doc in snapshot.docs) {
          log('here');
          // markMessagesAsRead();

          if (doc['sendId'] != widget.uid) {
            log('Updating isRead to true');

            doc.reference.update({'isRead': true});
          }
        }
      }
      // // setState(
      // //   () {
      // //     isChatScreen = false;
      // //   },
      // );
      // log('chat screen is$isChatScreen');
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    isChatScreen = false;
    super.dispose();
  }

  final messageController = TextEditingController();
  bool isMessageEmpty = true;
  final focusNode = FocusNode();
  bool isKeyboardVisible = false;
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    log(bottomPadding.toString());
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.user.name,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageController>(builder: (context, value, _) {
              log(value.messages.length.toString());
              if (value.isloading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return value.messages.isNotEmpty
                  ? ListView.builder(
                      itemCount: value.messages.length,
                      controller: value.scrollController,
                      itemBuilder: (context, index) {
                        final isMe = value.messages[index].sendId ==
                            context.read<AuthController>().appUser!.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: MessgeBubble(
                            otherUser: widget.user,
                            messageModel: value.messages[index],
                            user: context.read<AuthController>().appUser!,
                            isMe: isMe,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('Start Your Chat !'),
                    );
            }),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 5, bottom: 5, right: 5, top: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                left: 10,
                bottom: isKeyboardVisible ? 30 : 10,
                right: 10,
                top: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: messageController,
                      builder: (context, value, child) {
                        return TextField(
                          // scrollPadding: EdgeInsets.only(
                          //     bottom: MediaQuery.of(context).viewInsets.bottom),
                          maxLines: null,
                          minLines: 1,
                          controller: messageController,
                          decoration: Data().decoration(
                            context,
                            'Write Something ...',
                            null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: isMessageEmpty
                        ? null
                        : () async {
                            print('object');
                            final message = MessageModel(
                                message: messageController.text.trim(),
                                recieveId: widget.user.id,
                                sendId: widget.uid,
                                sentTime: DateTime.now());

                            print(isChatScreen.toString());

                            messageController.clear();
                            await context.read<MessageController>().sendMessage(
                                message: message,
                                senderId: widget.uid,
                                recieverId: widget.user.id,
                                user: widget.user);
                            // await markMessagesAsRead();
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMessageEmpty
                            ? Colors.grey.shade300
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 15),
                      child: Image.asset(
                        'assets/images/send.png',
                        height: 20,
                        color: isMessageEmpty ? Colors.black : Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
