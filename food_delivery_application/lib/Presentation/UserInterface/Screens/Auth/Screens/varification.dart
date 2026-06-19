// import 'package:flutter/material.dart';
// import 'package:food_delivery_app_project/Data/DataSource/Resources/assets.dart';
// import 'package:food_delivery_app_project/Data/DataSource/Resources/gap.dart';
// import 'package:food_delivery_app_project/Data/DataSource/Resources/input_decoration.dart';
// import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
// import 'package:food_delivery_app_project/Data/DataSource/Resources/strings.dart';
// import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
// import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';
// import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/location_access.dart';
// import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/signup.dart';

// class VerificationScreen extends StatefulWidget {
//   const VerificationScreen({
//     super.key,
//   });

//   @override
//   State<VerificationScreen> createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   @override
//   Widget build(BuildContext context) {
//     double height = ScreenDimensions.screenHeight(context);
//     double width = ScreenDimensions.screenWidth(context);

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           height: height,
//           width: width,
//           decoration: BoxDecoration(
//             color: const Color(0xff121223),
//             image: DecorationImage(
//               fit: BoxFit.contain,
//               alignment: Alignment.topCenter,
//               image: AssetImage(
//                 Images.bg,
//               ),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(top: 60),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(
//                               builder: (context) => const SignUpScreen()),
//                         );
//                       },
//                       child: Container(
//                           decoration: const BoxDecoration(
//                               color: Colors.white, shape: BoxShape.circle),
//                           height: height * 0.11,
//                           width: width * 0.12,
//                           child: const Icon(Icons.arrow_back_ios_outlined)),
//                     ),
//                   ),
//                 ),
//                 Text(
//                   AppStrings.verification,
//                   style: TextStyles.largeSen(context),
//                 ),
//                 Gap.verticalSpace(height * 0.02),
//                 Text(
//                   AppStrings.weHaveSent,
//                   style: TextStyles.medSen(context),
//                 ),
//                 Gap.verticalSpace(height * 0.01),
//                 Text(
//                   AppStrings.emailFormat,
//                   style: TextStyles.medSen(context)
//                       .copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 Gap.verticalSpace(height * 0.03),
//                 const BottomSheet()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class BottomSheet extends StatelessWidget {
//   const BottomSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double height = ScreenDimensions.screenHeight(context);
//     double width = ScreenDimensions.screenWidth(context);
//     return Expanded(
//       child: Container(
//         height: height * 0.66,
//         width: width,
//         decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30), topRight: Radius.circular(30))),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     AppStrings.code,
//                     style: TextStyles.ragularSen(context),
//                   ),
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: AppStrings.resend,
//                           style: TextStyles.ragularSen(context)
//                               .copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         TextSpan(
//                           text: AppStrings.inSec,
//                           style: TextStyles.ragularSen(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Gap.verticalSpace(height * 0.02),
//               Row(
//                 children: [
//                   Gap.horizontalSpace(height * 0.03),
//                   VerificationCube(height: height, width: width),
//                   Gap.horizontalSpace(height * 0.02),
//                   VerificationCube(height: height, width: width),
//                   Gap.horizontalSpace(height * 0.02),
//                   VerificationCube(height: height, width: width),
//                   Gap.horizontalSpace(height * 0.02),
//                   VerificationCube(height: height, width: width),
//                 ],
//               ),
//               Gap.verticalSpace(height * 0.02),
//               Buttons(
//                 isloading: false,
//                 width: width,
//                 height: height,
//                 title: AppStrings.verify,
//                 widgets: null,
//                 ontap: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                         builder: (context) => const LocationAccessScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class VerificationCube extends StatelessWidget {
//   const VerificationCube({
//     super.key,
//     required this.height,
//     required this.width,
//   });

//   final double height;
//   final double width;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height * 0.07,
//       width: width * 0.15,
//       child: TextFormField(
//         decoration: Data().decoration(context, null, null),
//       ),
//     );
//   }
// }
