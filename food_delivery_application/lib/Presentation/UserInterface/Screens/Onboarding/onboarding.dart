import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/screen_dimension.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/text_styles.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Commens/button.dart';
import 'package:food_delivery_app_project/Presentation/UserInterface/Screens/Auth/Screens/user_or_chef.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final ValueNotifier<int> currentIndex = ValueNotifier(0);
  final PageController _pageController = PageController(initialPage: 0);

  final List<Map<String, String>> onboardingData = [
    {
      'title': "All your favorites",
      'description':
          "Get all your loved foods in one place, just place the order we will do the rest.",
      'image': "assets/images/onboarding1.PNG",
    },
    {
      'title': "Order from choosen chef",
      'description':
          "Embark on personalized flavor journeys by ordering online from your favorite chef.",
      'image': "assets/images/onboarding2.PNG",
    },
    {
      'title': "Free delivery offers",
      'description':
          "Indulge in the convenience of free delivery with exclusive offers on our online food delivery app.",
      'image': "assets/images/onboarding3.PNG",
    },
  ];

  void nextPage() {
    if (currentIndex.value < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const UserOrChef()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = ScreenDimensions.screenHeight(context);
    double width = ScreenDimensions.screenWidth(context);
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 30),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentIndex.value = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return buildPageContent(
                      onboardingData[index]['title']!,
                      onboardingData[index]['description']!,
                      onboardingData[index]['image']!,
                      index == onboardingData.length - 1,
                    );
                  },
                ),
                Positioned(
                  bottom: 130,
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < onboardingData.length; i++)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: ShapeDecoration(
                              color: currentIndex.value == i
                                  ? AppColor.orangeColor
                                  : AppColor.lightOrangeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: currentIndex,
                        builder: (context, value, child) {
                          return Buttons(
                            isloading: false,
                            width: width,
                            height: height,
                            title: value == onboardingData.length - 1
                                ? 'Get Started'
                                : 'Next',
                            ontap: value == onboardingData.length - 1
                                ? navigateToLoginScreen
                                : nextPage,
                          );
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      InkWell(
                        onTap: () {
                          navigateToLoginScreen();
                        },
                        child: Text(
                          "Skip",
                          style: TextStyles.medSen(context).copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPageContent(
      String title, String description, String image, bool isLastPage) {
    return Column(
      children: [
        Image.asset(
          image,
          width: 374,
          height: 345.3,
        ),
        const SizedBox(height: 45),
        SizedBox(
          width: 380,
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    TextStyles.largeSen(context).copyWith(color: Colors.black),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: 390,
                height: 110,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyles.ragularSen(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
