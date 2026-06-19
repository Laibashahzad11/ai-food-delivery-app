import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:food_delivery_app_project/Data/DataSource/Resources/image_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/media_query.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/validator.dart';
import 'package:food_delivery_app_project/Domain/model/product_model.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/chef_text_field.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/location_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/controller/product_controller.dart';
import 'package:food_delivery_app_project/Presentation/Chief/Commons/normal_button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/Auth/Contollers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddNewItem extends StatefulWidget {
  final ProductModel? product;
  const AddNewItem({super.key, this.product});

  @override
  State<AddNewItem> createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  // ... existing ingredients ...
  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();
  final productDiscriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool? isSelected = false;
  XFile? selectedImage;
  bool isloading = false;
  String? catagory;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      productNameController.text = widget.product!.productName;
      productPriceController.text = widget.product!.productPrice.toString();
      productDiscriptionController.text = widget.product!.productDiscription;
      catagory = widget.product!.catagory;
      isAvailable = widget.product!.isAvailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Item' : 'Add New Items',
          style: const TextStyle(fontSize: 17),
        ),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Product?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  )
                );
                if (confirm == true) {
                  await context.read<ProductController>().deleteProduct(
                    widget.product!.productUid,
                    widget.product!.productId
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          TextButton(
              onPressed: () {
                productNameController.clear();
                productPriceController.clear();
                productDiscriptionController.clear();
                selectedImage = null;
                setState(() {
                  catagory = null;
                });
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColor.orangeColor),
              ))
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  children: [
                    Text('Item Name'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ChefTextField(
                  validator: Validate.name,
                  controller: productNameController,
                  hint: 'Zinger Burger',
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Upload photo/video',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 70,
                    );

                    setState(() {
                      selectedImage = image;
                    });
                  },
                  child: selectedImage != null
                      ? Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(selectedImage!.path),
                                height: 100, // Set the desired height
                                width: 100, // Set the desired width
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: AppColor.orangeColor,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        )
                      : (isEdit && widget.product!.productImage.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: _buildProductImage(widget.product!.productImage),
                            )
                          : DottedBorder(
                              radius: const Radius.circular(50),
                              color: Colors.grey.shade300,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffECEAF5),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Image.asset('assets/images/upload.png'),
                                ),
                              ),
                            ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Row(
                  children: [
                    Text('Price'),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ChefTextField(
                        keyboardType: TextInputType.number,
                        validator: Validate.number,
                        controller: productPriceController,
                        hint: 'Rs: 60',
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            activeColor: AppColor.orangeColor,
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                isSelected = value;
                              });
                            },
                          ),
                          const Text(
                            'Pick Up',
                            style: TextStyle(
                                color: Color(0xff9C9BA6), fontSize: 13),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            activeColor: AppColor.orangeColor,
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                isSelected = value;
                              });
                            },
                          ),
                          const Text('Add',
                              style: TextStyle(
                                  color: Color(0xff9C9BA6), fontSize: 13))
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: screenHeight(context) * 0.20,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Discription'),
                        const SizedBox(
                          height: 10,
                        ),
                        ChefTextField(
                          validator: Validate.name,
                          controller: productDiscriptionController,
                          maxLines: 4,
                          hint: 'Add Something About Product',
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    DropdownButton<String>(
                      hint: const Text('Select Catagory'),
                      iconEnabledColor: AppColor.orangeColor,
                      value: catagory,
                      items: <String>[
                        'Burger',
                        'Pizza',
                        'Sandwich',
                        'Nuggets',
                        'Soup',
                        'Other',
                      ].map((String value2) {
                        return DropdownMenuItem<String>(
                          value: value2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              value2,
                              style:
                                  const TextStyle(color: AppColor.orangeColor),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value1) {
                        setState(() {
                          catagory = value1!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      activeColor: AppColor.orangeColor,
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value ?? true;
                        });
                      },
                    ),
                    Text(
                      isAvailable ? 'Available' : 'Out of Stock',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: NormalButton(
                    isloading: isloading,
                    text: isEdit ? 'UPDATE PRODUCT' : 'UPLOAD PRODUCT',
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        if (selectedImage == null && !isEdit) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("upload product image"),
                            ),
                          );
                          return;
                        }
                        if (catagory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("please select catagory"),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          isloading = true;
                        });
                        try {
                          final locationController = context.read<GetPermissionLocation>();
                          final currentPos = locationController.currentPosition;
                          
                          final product = ProductModel(
                              location: UserLocation(
                                  lat: currentPos?.latitude ?? 30.1575,
                                  lon: currentPos?.longitude ?? 71.5249),
                              catagory: catagory!,
                              productDiscription:
                                  productDiscriptionController.text,
                              productImage: isEdit ? widget.product!.productImage : '',
                              productName:
                                  productNameController.text.toUpperCase(),
                              productPrice: double.tryParse(productPriceController.text) ?? 0.0,
                              productId: isEdit ? widget.product!.productId : const Uuid().v1(),
                              productUid:
                                  context.read<AuthController>().appUser!.id,
                              isAvailable: isAvailable,
                              productOwner: context
                                  .read<AuthController>()
                                  .appUser!
                                  .resturantName);

                          if (isEdit) {
                            // If new image selected, we still need logic to upload it, 
                            // but for now let's assume updateProduct handles image if passed.
                            // In this app, addProduct takes image, updateProduct doesn't yet.
                            // I'll stick to addProduct which actually handles the upload.
                            await context
                                .read<ProductController>()
                                .addProduct(product, selectedImage);
                          } else {
                            await context
                                .read<ProductController>()
                                .addProduct(product, selectedImage);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColor.mediumOrangeColor,
                              content: Text(isEdit ? "Product Updated" : "Product Uploaded"),
                            ),
                          );
                          if (!isEdit) {
                            productNameController.clear();
                            productPriceController.clear();
                            productDiscriptionController.clear();
                            selectedImage = null;
                            setState(() {
                              catagory = null;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                          setState(() {
                            isloading = false;
                          });
                        } catch (e) {
                          setState(() {
                            isloading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("There was an issue $e")));
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String image) {
    return buildProductImage(image, width: 100, height: 100);
  }
}
