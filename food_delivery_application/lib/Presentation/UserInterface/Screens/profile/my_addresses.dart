import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Domain/model/address_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/address_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/add_new_address.dart';
import 'package:provider/provider.dart';

class MyAddresses extends StatefulWidget {
  const MyAddresses({super.key});

  @override
  State<MyAddresses> createState() => _MyAddressesState();
}

class _MyAddressesState extends State<MyAddresses> {
  List<Map<String, dynamic>> home = [
    {
      'label': 'HOME',
      'address': '2464 Royal Ln. Mesa, New Jersey 45463',
    },
    {
      'label': 'OFFICE',
      'address': '3891 Ranchview Dr. Richardson, California 62639',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNewAddress(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: AppColor.orangeColor,
                ),
              ),
            )
          ],
          title: const Text('Address'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('addresses')
              .doc(context.read<AuthController>().appUser!.id)
              .collection('adress')
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs
                .map((e) => AddressModel.fromJson(e.data()))
                .toList();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Handle errors appropriately
            } else if (!snapshot.hasData || data!.isEmpty) {
              return const Center(
                child: Text(
                  'No Address',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final data1 = data[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      tileColor: AppColor.lightWightColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: data1.label == 'Home'
                            ? Image.asset(
                                'assets/images/Home.png',
                                color: AppColor.orangeColor,
                              )
                            : Image.asset(
                                'assets/images/office.png',
                                color: AppColor.purpleColor,
                              ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data1.label,
                            style: const TextStyle(fontSize: 16),
                          ),
                          GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      actionsPadding: const EdgeInsets.all(20),
                                      content: const Text('Are you sure? '),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await context
                                                .read<AddressController>()
                                                .deleteAddress(address: data1);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Image.asset('assets/images/delete.png')),
                        ],
                      ),
                      subtitle: Text(
                        data1.address,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                });
          },
        ));
  }
}
