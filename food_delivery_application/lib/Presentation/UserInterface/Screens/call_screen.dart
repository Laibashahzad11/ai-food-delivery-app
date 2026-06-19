import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';

class CallSceen extends StatelessWidget {
  const CallSceen({
    super.key,
    required this.productModel,
  });
  final ProductModel productModel;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        // body: SafeArea(
        //   child: ZegoUIKitPrebuiltCall(
        //       controller: ZegoUIKitPrebuiltCallController(),
        //       appID: app_id,
        //       appSign: app_signIn,
        //       callID: productModel.productUid,
        //       userID: productModel.productId,
        //       userName: productModel.productOwner,
        //       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        //         ..audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
        //           foregroundBuilder: (BuildContext context, Size size,
        //               ZegoUIKitUser? user, Map extraInfo) {
        //             return user != null
        //                 ? Positioned(
        //                     bottom: 5,
        //                     left: 5,
        //                     child: Container(
        //                       width: 60,
        //                       height: 60,
        //                       decoration: BoxDecoration(
        //                         shape: BoxShape.circle,
        //                         image: DecorationImage(
        //                           image: NetworkImage(
        //                             productModel.productImage,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   )
        //                 : const SizedBox();
        //           },
        //         )
        //         ..background = Container(
        //           color: Colors.white,
        //           width: screenWidth(context),
        //           height: screenHeight(context),
        //         )

        //       // ..foreground = Container(
        //       //   color: Colors.black,
        //       //   width: screenWidth(context),
        //       //   height: screenHeight(context),
        //       // ),

        //       ),
        // ),
        );
  }
}
