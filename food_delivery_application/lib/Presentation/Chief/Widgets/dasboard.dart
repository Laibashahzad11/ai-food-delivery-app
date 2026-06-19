import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/add_new_item.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Domain/model/user_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/review_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/popular_items.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/request_orders.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/running_orders.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Widgets/reviews.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isloading = false;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isloading = true;
      });
      
      final auth = context.read<AuthController>();
      final prod = context.read<ProductController>();
      final rev = context.read<ReviewController>();
      final uid = auth.appUser?.id ?? '';

      if (uid.isNotEmpty) {
        // Parallel data fetching for all required chef stats
        await Future.wait([
          rev.reviewLength(uid: uid),
          rev.getReviewAverage(uid: uid),
          prod.receiveOrdersLength(uid: uid),
          prod.runningOrdersLength(uid: uid),
          context.read<GetPermissionLocation>().getPermission(),
          if (prod.productList.isEmpty) prod.getProducts(),
        ]);
      }

      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    });
    super.initState();
  }

  String formattedOrderCount(int count) {
    return count.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image.asset('assets/images/Menu.png'),
              title: const Text(
                'Location',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              subtitle: Consumer<GetPermissionLocation>(
                builder: (context, location, _) {
                  return Text(
                    location.currentDistrict ?? 'Fetching location...',
                    style: const TextStyle(fontSize: 13),
                  );
                },
              ),
              trailing: CircleAvatar(
                backgroundImage: context.watch<AuthController>().appUser?.userImage != null && 
                                 context.watch<AuthController>().appUser!.userImage!.isNotEmpty
                  ? NetworkImage(context.watch<AuthController>().appUser!.userImage!)
                  : const AssetImage('assets/images/default_chef.png') as ImageProvider,
                radius: 30,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    showDragHandle: true,
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 660,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(context
                                  .watch<AuthController>()
                                  .appUser
                                  ?.id ?? '')
                              .collection('runningOrders')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final orderCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    '$orderCount Running Orders',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (snapshot.hasError)
                                  const Expanded(
                                    child: Center(
                                      child: Text('Error loading orders'),
                                    ),
                                  )
                                else if (orderCount == 0)
                                  const Expanded(
                                    child: Center(
                                      child: Text('No Running Orders Found'),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: orderCount,
                                      itemBuilder: (context, index) {
                                        try {
                                          final doc = snapshot.data!.docs[index];
                                          final productData = doc.data();
                                          final product = ProductModel.fromJson(productData);
                                          final user = productData['user'] != null 
                                              ? UserModel.fromJson(productData['user'] as Map<String, dynamic>)
                                              : UserModel(
                                                  id: '',
                                                  name: 'Unknown',
                                                  email: '',
                                                  role: '',
                                                  phoneNumber: '',
                                                  bio: '',
                                                  resturantName: '',
                                                );
                                          final docId = productData['docId'] ?? doc.id;

                                          return RunningOrders(
                                            user: user,
                                            product: product,
                                            docId: docId.toString(),
                                          );
                                        } catch (e) {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(
                          begin: 0,
                          end:
                              context.watch<ProductController>().runningLength),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return isloading
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: CircularProgressIndicator(
                                    color: AppColor.lightOrangeColor,
                                  ),
                                ),
                              )
                            : Text(
                                formattedOrderCount(value),
                                style: const TextStyle(fontSize: 50),
                              );
                      },
                    ),
                    const Text('RUNNING ORDERS'),
                  ],
                ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      showDragHandle: true,
                      context: context,
                      builder: (context) {
                        return Builder(builder: (context) {
                          return SizedBox(
                            height: 660,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                    '${context.read<ProductController>().receiveLength.toString()} Order Requests', // Add your desired text here
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(context
                                            .read<AuthController>()
                                            .appUser!
                                            .id)
                                        .collection('receiveOrders')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      // final data = snapshot.data?.docs
                                      //     .map((e) =>
                                      //         ProductModel.fromJson(e.data()))
                                      //     .toList();
                                      // log(snapshot.data?.docs
                                      //     .map((e) => e.data()));
                                      // print(data?.length ?? 0);
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Text('data');
                                      } else if (!snapshot.hasData) {
                                        return const Text('Empty');
                                      }
                                      final data =
                                          snapshot.data!.docs.map((doc) {
                                        log(doc.id);
                                        final productData = doc.data();
                                        return {
                                          'product': ProductModel.fromJson(
                                              productData),
                                          'user': productData['user'] != null 
                                              ? UserModel.fromJson(productData['user'] as Map<String, dynamic>)
                                              : UserModel(
                                                  id: '',
                                                  name: 'Unknown',
                                                  email: '',
                                                  role: '',
                                                  phoneNumber: '',
                                                  bio: '',
                                                  resturantName: '',
                                                ),
                                          'docId': productData['docId'] ?? doc.id,
                                        };
                                      }).toList();
                                      // log(data.toString());
                                      return ListView.builder(
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {
                                          final product = data[index]['product']
                                              as ProductModel;
                                          final user =
                                              data[index]['user'] as UserModel;
                                          final docId =
                                              data[index]['docId'].toString();

                                          log(docId);
                                          return RequestOrders(
                                            docId: docId,
                                            user: user,
                                            product: product,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedOrderCount(
                            context.watch<ProductController>().receiveLength),
                        style: const TextStyle(fontSize: 50),
                      ),
                      const Text('ORDER REQUEST')
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Revenue'),
                  Text(
                    'Rs. 2,241',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                child: DropdownButton(
                  hint: const Text('Daily'),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'one',
                      child: Text('One'),
                    )
                  ],
                  onChanged: (value) {},
                ),
              ),
              const Text(
                'See Details',
                style: TextStyle(
                    color: Colors.deepOrange,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.deepOrange),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              color: Colors.orange.shade100,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews'),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewScreen(),
                    ),
                  );
                },
                child: const Text(
                  'See All Reviews',
                  style: TextStyle(
                      color: Colors.deepOrange,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.deepOrange),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                  'Total ${context.watch<ReviewController>().userReviewLength} Reviews')
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Products'),
              Text(
                'See All',
                style: TextStyle(
                    color: Colors.deepOrange,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.deepOrange),
              )
            ],
          ),
          Expanded(
            child: SizedBox(
              height: 200,
              child: StreamBuilder<List<ProductModel>>(
                stream: context.read<ProductController>().chefProductsStream(
                  context.read<AuthController>().appUser!.id
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products added yet.'));
                  }
                  final products = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNewItem(
                                product: products[index],
                              ),
                            ),
                          );
                        },
                        child: PopularItems(product: products[index]),
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
