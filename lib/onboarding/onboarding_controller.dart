// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pinalprojectbark/pages/login_page.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  // Varibles
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  get deviceStorage => null;

  // Update Current Index when page Scroll.
  void updatePageIndicator(index) => currentPageIndex.value = index;

  // Jump to the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  // Update Current Index & jump to the next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      final storage = GetStorage();

      if (kDebugMode) {
        print('=============== GET STORAGE Next Button ===============');
        print(storage.read('isFirstTime'));
      }

      storage.write('isFirstTime', false);

      if (kDebugMode) {
        print('=============== GET STORAGE Next Button ===============');
        print(storage.read('isFirstTime'));
      }

      Get.offAll(() => const LoginPage(token: null));
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // Update Current Index & jump to the last Page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }
}
