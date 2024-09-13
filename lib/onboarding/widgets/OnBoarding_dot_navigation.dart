// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:pinalprojectbark/constants/colors.dart';
import 'package:pinalprojectbark/constants/device_utility.dart';
import 'package:pinalprojectbark/constants/helper_functions.dart';
import 'package:pinalprojectbark/constants/sizes.dart';
import 'package:pinalprojectbark/onboarding/onboarding_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: TSizes.defaultSpace,
      child: SmoothPageIndicator(
        count: 3,
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        effect: ExpandingDotsEffect(
            activeDotColor: dark ? TColors.light : TColors.dark, dotHeight: 6),
      ),
    );
  }
}
