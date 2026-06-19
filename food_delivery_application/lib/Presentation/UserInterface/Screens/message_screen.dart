import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
import 'package:food_delivery_app_project/Domain/model/message_model.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/message_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({
    super.key,
    required this.product,
    required this.user,
  });
  final UserModel user;
  final ProductModel product;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<MessageController>().getAllMessages(
        recieverId: widget.product.productUid, senderId: widget.user.id);

    messageController.addListener(() {
      setState(() {
        // Update the state based on whether the messageController is empty or not
        isMessageEmpty = messageController.text.isEmpty;
      });
    });
    focusNode.addListener(() {
      setState(() {
        isKeyboardVisible = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  final messageController = TextEditingController();
  bool isMessageEmpty = true;
  final focusNode = FocusNode();
  bool isKeyboardVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.productOwner,
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
                            messageModel: value.messages[index],
                            user: context.read<AuthController>().appUser!,
                            otherUser: widget.user,
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
                bottom: isKeyboardVisible ? 55 : 10,
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
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isMessageEmpty ? Colors.grey.shade300 : Colors.orange,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: GestureDetector(
                      onTap: isMessageEmpty
                          ? null
                          : () async {
                              final message = MessageModel(
                                  message: messageController.text.trim(),
                                  recieveId: widget.product.productUid,
                                  sendId: widget.user.id,
                                  sentTime: DateTime.now());
                              print('object');

                              messageController.clear();
                              await context
                                  .read<MessageController>()
                                  .sendMessage(
                                      message: message,
                                      senderId: widget.user.id,
                                      recieverId: widget.product.productUid,
                                      user: widget.user);
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
