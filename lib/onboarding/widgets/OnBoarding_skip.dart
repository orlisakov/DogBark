// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:pinalprojectbark/constants/device_utility.dart';
import 'package:pinalprojectbark/constants/sizes.dart';
import 'package:pinalprojectbark/onboarding/onboarding_controller.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: TDeviceUtils.getAppBarHeight(),
        right: TSizes.defaultSpace,
        child: TextButton(
          onPressed: () => OnBoardingController.instance.skipPage(),
          child: const Text(
            'Skip',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ));
  }
}
