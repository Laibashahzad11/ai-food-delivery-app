import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';

class FoodDetails extends StatelessWidget {
  const FoodDetails({
    this.product,
    super.key,
  });
  final ProductModel? product;
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> ingridents = [
      {
        'text': 'Salt',
        'image': 'assets/images/Salt.png',
      },
      {'text': 'Onion', 'image': 'assets/images/Onion.png'},
      {'text': 'Salt', 'image': 'assets/images/Salt.png'},
      {'text': 'Onion', 'image': 'assets/images/Onion.png'},
      {'text': 'Salt', 'image': 'assets/images/Salt.png'},
      {'text': 'Garlic', 'image': 'assets/images/Garlic.png'},
      {'text': 'Salt', 'image': 'assets/images/Salt.png'},
      {'text': 'Salt', 'image': 'assets/images/Salt.png'},
      {'text': 'Garlic', 'image': 'assets/images/Garlic.png'},
    ];

    return Scaffold(
      // bottomNavigationBar: NavBar(currentIndex: currentIndex, onTap: onTap),
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Food Details'),
        actions: [
          TextButton(
              onPressed: () {},
              child: const Text(
                'EDIT',
                style: TextStyle(color: AppColor.orangeColor),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          height: screenHeight(context),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildProductImage(
                      product?.productImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product!.productName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Rs. ${product!.productPrice}')
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.pin_drop,
                        size: 16,
                      ),
                      Text(
                        'Multan, Pakistan',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.deepOrange,
                      ),
                      Text(
                        '  ${product!.productRating ?? 'No rating'}',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              const Row(
                children: [
                  Text('INGRIDENTS'),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Center(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingridents.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: AppColor.lightOrangeColor,
                                borderRadius: BorderRadius.circular(30)),
                            child: Image.asset(ingridents[index]['image']),
                          ),
                          Text(
                            ingridents[index]['text'],
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Discription',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(product!.productDiscription)
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
