import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinalprojectbark/constants/sizes.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/onboarding/onboarding_controller.dart';
import 'package:pinalprojectbark/onboarding/widgets/OnBoarding_dot_navigation.dart';
import 'package:pinalprojectbark/onboarding/widgets/OnBoarding_next_button.dart';
import 'package:pinalprojectbark/onboarding/widgets/OnBoarding_skip.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // OnBoarding Controller to handle Logic
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Horizontally Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: "assets/images/logoMe.png",
                title: "ברוכים הבאים לאפליקציה שלנו",
                subTitle:
                    "האפליקציה שלנו מחברת בין מאלפי כלבים לבעלי כלבים בקלות, בצורה פשוטה ונגישה. ולהנות מתהליך האילוף בצורה מקסימלית",
                textColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
                imageWidth: 400,
                imageHeight: 300,
              ),
              OnBoardingPage(
                image: "assets/images/on_boarding_images/dogPic2.jpg",
                title: "🐾 ?מוכן להתחיל לאלף ",
                subTitle:
                    "בעלי כלבים יוכלו לצפות בפרופיל שלך וליצור איתך קשר, להנות מהפוסטים שלך ומחווית האילוף המשותפת שלכם",
                textColor: Color.fromARGB(255, 255, 255, 255),
                backgroundColor: Color.fromARGB(255, 212, 107, 76),
                imageWidth: 400,
                imageHeight: 300,
              ),
              OnBoardingPage(
                image: "assets/images/on_boarding_images/dogPic3.jpg",
                title: "הצטרף למסע עם החבר הכי טוב  \n🐶שלך",
                subTitle:
                    "התחברו עם מאלפים מוסמכים, בקשו הדרכה אישית, קבלו משימות בית והזמינו פגישות בצורה קלה ונוחה",
                textColor: Color.fromARGB(255, 255, 255, 255),
                backgroundColor: Color.fromARGB(183, 76, 104, 40),
                imageWidth: 300,
                imageHeight: 250,
              ),
            ],
          ),

          // Skip Button
          const OnBoardingSkip(),

          // Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          // Circular Button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.title,
    required this.subTitle,
    required this.image,
    required this.textColor,
    required this.backgroundColor,
    this.imageWidth,
    this.imageHeight,
  });

  final String image, title, subTitle;
  final Color textColor, backgroundColor;
  final double? imageWidth, imageHeight; // Nullable properties for image size

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 300,
            height: 300,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontFamily: 'Alef',
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
