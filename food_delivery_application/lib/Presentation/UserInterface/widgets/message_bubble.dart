import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/message_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:intl/intl.dart';

class MessgeBubble extends StatelessWidget {
  const MessgeBubble({
    required this.isMe,
    required this.user,
    required this.messageModel,
    required this.otherUser,
    super.key,
  });

  final bool isMe;
  final UserModel user;
  final UserModel otherUser;
  final MessageModel messageModel;

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    final messageWidth = MediaQuery.of(context).size.width / 1.75;
    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: isMe
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    messageModel.isRead
                        ? const Icon(Icons.done_all)
                        : const Icon(Icons.done),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: messageWidth,
                      ),
                      margin: isMe
                          ? const EdgeInsets.only(
                              right: 10, top: 10, bottom: 10, left: 10)
                          : const EdgeInsets.only(
                              right: 100, top: 10, bottom: 10, left: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColor.messageColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            messageModel.message,
                            style: TextStyle(
                                fontSize: 15,
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColor.lightOrangeColor,
                      // backgroundImage:
                      //     user!.userImage != null ? NetworkImage(user.userImage!) : null,
                      child: user.userImage != null
                          ? Container(
                              height: screenHeight(context),
                              width: screenWidth(context),
                              // margin: EdgeInsets.all(5),
                              // padding: EdgeInsets.all(5),
                              clipBehavior: Clip.antiAlias,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: user.userImage!,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                  color: AppColor.orangeColor,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ))
                          : Container(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: Text(
                    DateFormat('h:mm:aa').format(messageModel.sentTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                )
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.lightOrangeColor,
                      // backgroundImage:
                      //     user!.userImage != null ? NetworkImage(user.userImage!) : null,
                      child: otherUser.userImage != null
                          ? Container(
                              height: screenHeight(context),
                              width: screenWidth(context),
                              // margin: EdgeInsets.all(5),
                              // padding: EdgeInsets.all(5),
                              clipBehavior: Clip.antiAlias,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: otherUser.userImage!,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                        color: AppColor.blueColor,
                                      ),
                                  errorWidget: (context, url, error) {
                                    print(error);
                                    return const Icon(Icons.error);
                                  }))
                          : Container(),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: messageWidth,
                      ),
                      margin: isMe
                          ? const EdgeInsets.only(
                              right: 10, top: 10, bottom: 10, left: 100)
                          : const EdgeInsets.only(
                              right: 100, top: 10, bottom: 10, left: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: isMe
                              ? AppColor.messageColor
                              : AppColor.lightGreyColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            messageModel.message,
                            style: TextStyle(
                                fontSize: 15,
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    DateFormat('h:mm:aa').format(messageModel.sentTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                )
              ],
            ),
    );
  }
}
