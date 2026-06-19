import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Domain/model/address_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/chef_text_field.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/address_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AddNewAddress extends StatefulWidget {
  const AddNewAddress({super.key});

  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  bool isloading = false;
  final addressController = TextEditingController();
  final streetController = TextEditingController();
  final postalController = TextEditingController();
  final apartmentController = TextEditingController();
  String label = '';
  static const LatLng loc = LatLng(37.4223, -10.0848);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: AppColor.lightOrangeColor,
          height: screenHeight(context) * 0.35,
          width: double.infinity,
          child: GoogleMap(
            onTap: (argument) {
              print(argument);
            },
            initialCameraPosition: CameraPosition(
                target: context.read<GetPermissionLocation>().currentPosition ??
                    loc,
                zoom: 5),
            markers: {
              Marker(
                markerId: const MarkerId('value'),
                icon: BitmapDescriptor.defaultMarker,
                position:
                    context.read<GetPermissionLocation>().currentPosition ??
                        loc,
              )
            },
          ),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: SizedBox(
                  height: screenHeight(context) * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ADDRESS'),
                          ChefTextField(
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'Address field cant be null';
                                }
                                return null;
                              },
                              hint: '3235 Royal Ln. mesa, new jersy 34567',
                              controller: addressController),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('STREET'),
                                ChefTextField(
                                    validator: (val) {
                                      // var nameRegex = RegExp(r"^[a-z A-Z]+$").hasMatch(val!);
                                      if (val!.isEmpty) {
                                        return 'Street field cant be empty';
                                      }
                                      return null;
                                    },
                                    hint: 'Gulbahar',
                                    controller: streetController)
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('POSTAL CODE'),
                                ChefTextField(
                                    keyboardType: TextInputType.number,
                                    validator: Validate.number,
                                    hint: '25000',
                                    controller: postalController)
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('APARTMENT'),
                          ChefTextField(
                              validator: (val) {
                                // var nameRegex = RegExp(r"^[a-z A-Z]+$").hasMatch(val!);
                                if (val!.isEmpty) {
                                  return 'Street field cant be empty';
                                }
                                return null;
                              },
                              hint: 'hint',
                              controller: apartmentController),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                label = 'Home';
                              });
                              print(label);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: label == 'Home'
                                      ? AppColor.mediumOrangeColor
                                      : AppColor.lightGreyColor,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Text(
                                'Home',
                                style: TextStyle(
                                    color: label == 'Home'
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                label = 'Work';
                              });
                              print(label);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: label == 'Work'
                                      ? AppColor.mediumOrangeColor
                                      : AppColor.lightGreyColor,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Text(
                                'Work',
                                style: TextStyle(
                                    color: label == 'Work'
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                label = 'Other';
                              });
                              print(label);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                  color: label == 'Other'
                                      ? AppColor.mediumOrangeColor
                                      : AppColor.lightGreyColor,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Text(
                                'Other',
                                style: TextStyle(
                                    color: label == 'Other'
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          )
                        ],
                      ),
                      NormalButton(
                          onTap: () async {
                            setState(() {
                              isloading = true;
                            });
                            try {
                              final addressModel = AddressModel(
                                  address: addressController.text,
                                  apartment: apartmentController.text,
                                  label: label,
                                  postalCode: postalController.text,
                                  street: streetController.text,
                                  uid: context
                                      .read<AuthController>()
                                      .appUser!
                                      .id);
                              await context
                                  .read<AddressController>()
                                  .addAddress(address: addressModel);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor:
                                          AppColor.mediumOrangeColor,
                                      content: Text("Location Added")));
                              setState(() {
                                isloading = false;
                              });
                            } catch (e) {
                              setState(() {
                                isloading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("There was an issue $e")));
                            }
                          },
                          text: 'SAVE LOCATION',
                          isloading: isloading)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]));
  }
}
