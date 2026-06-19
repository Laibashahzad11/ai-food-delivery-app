import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Domain/model/message_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/message_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/notification_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/chef_message_screen.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<DocumentSnapshot> chatDocs = [];
  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    final length = await context
        .read<MessageController>()
        .chatLength(uid: context.read<AuthController>().appUser!.id);
    print('asdasda$length');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(
            'Notification',
            style: TextStyle(fontSize: 17),
          ),
        ),
        body: Column(
          children: [
            const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColor.orangeColor,
              indicatorColor: AppColor.orangeColor,
              tabs: [
                Tab(
                  child: Text('Notifications'),
                ),
                Tab(
                  child: Text('Messages'),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                Consumer<NotificationController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.notifications.isEmpty) {
                      return const Center(child: Text('No notifications yet.'));
                    }

                    return ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('assets/images/default_chef.png'),
                            ),
                            title: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.body,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  DateFormat('h:mm a').format(notification.timestamp),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            trailing: notification.type == 'new_order' 
                                ? const Icon(Icons.shopping_cart, color: Colors.orange)
                                : const CircleAvatar(radius: 5),
                          ),
                        );
                      },
                    );
                  },
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(context.read<AuthController>().appUser!.id)
                      .collection('chats')
                      // .orderBy('lastMessageTime', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        chatDocs.isEmpty) {
                      // Only show loading indicator if the chatDocs list is initially empty
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('An error occurred.'));
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      chatDocs = snapshot.data!.docs;
                    }

                    if (chatDocs.isEmpty) {
                      return const Center(child: Text('No chats available.'));
                    }

                    final userData = chatDocs
                        .map((e) => UserModel.fromJson(
                            e.data() as Map<String, dynamic>))
                        .toList();
                    userData.sort((b, a) {
                      final lastMessageTimeA = context
                              .read<MessageController>()
                              .lastMessageTime[a.id] ??
                          DateTime
                              .now(); // Default to current time if no message
                      final lastMessageTimeB = context
                              .read<MessageController>()
                              .lastMessageTime[b.id] ??
                          DateTime.now();
                      return lastMessageTimeA
                          .compareTo(lastMessageTimeB); // Ascending order
                    });

                    return ListView.builder(
                      itemCount: userData.length,
                      itemBuilder: (context, index) {
                        final user = userData[index];
                        log(user.name.toString());
                        final unreadCount = context
                            .watch<MessageController>()
                            .getUnreadCount(user.id);

                        return SingleUser(
                          user: user,
                          lastMessage: context
                                  .watch<MessageController>()
                                  .last[user.id] ??
                              '',
                          unReadOunt: unreadCount,
                        );
                      },
                    );
                  },
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

class SingleUser extends StatefulWidget {
  const SingleUser({
    super.key,
    required this.user,
    required this.lastMessage,
    required this.unReadOunt,
  });

  final UserModel user;
  final String lastMessage;
  final int unReadOunt;

  @override
  State<SingleUser> createState() => _SingleUserState();
}

class _SingleUserState extends State<SingleUser> {
  List<MessageModel> messages = []; // Track messages
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    // Fetch all messages initially
    fetchMessages();
  }

  // Method to fetch all messages
  Future<void> fetchMessages() async {
    // setState(() {
    //   isLoading = true; // Set loading state to true
    // });

    try {
      log('message');
      // Call the method to fetch messages
      messages = await context.read<MessageController>().getAllMessages(
          recieverId: widget.user.id,
          senderId: context.read<AuthController>().appUser!.id);

      // setState(() {
      //   isLoading = false; // Set loading state to false after fetching messages
      // });
    } catch (e) {
      // Handle any errors
      print('Error fetching messages: $e');
      // setState(() {
      //   isLoading = false; // Set loading state to false in case of error
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(messages);
    // int unreadCount = messages
    //     .where((msg) =>
    //         !msg.isRead &&
    //         msg.recieveId == context.read<AuthController>().appUser!.id)
    //     .length;
    // log('counttttis ${unreadCount.toString()}');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChefMessageScreen(
                  uid: context.read<AuthController>().appUser!.id,
                  user: widget.user,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          });
        },
        leading: Stack(
          children: [
            widget.user.userImage != null
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.user.userImage!),
                  )
                : const CircleAvatar(
                    radius: 30,
                  ),
            Positioned(
              bottom: 2,
              right: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                width: 14,
                height: 14,
              ),
            )
          ],
        ),
        title: SizedBox(
          child: Text(
            widget.user.name,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        subtitle: Text(
          widget.lastMessage,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              DateFormat('h:mm:aa').format(
                context
                        .watch<MessageController>()
                        .lastMessageTime[widget.user.id] ??
                    DateTime.now(),
              ),
              style: TextStyle(
                  color: widget.unReadOunt > 0 ? Colors.green : Colors.black),
            ),

            // index == 2 || index == 1

            if (widget.unReadOunt > 0)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                width: 20,
                height: 20,
                child: Center(
                  child: Text(
                    widget.unReadOunt.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
