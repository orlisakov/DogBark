// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinalprojectbark/constants/colors.dart';
import 'package:pinalprojectbark/constants/device_utility.dart';
import 'package:pinalprojectbark/constants/helper_functions.dart';
import 'package:pinalprojectbark/constants/sizes.dart';
import 'package:pinalprojectbark/onboarding/onboarding_controller.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Positioned(
      right: TSizes.defaultSpace,
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: dark ? TColors.primary : Colors.black),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
