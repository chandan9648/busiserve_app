import 'package:get/get.dart';

/// Bottom navigation for the four top-level tabs.
class MainController extends GetxController {
  static const home = 0, services = 1, work = 2, account = 3;
  final index = 0.obs;

  void changeTab(int i) => index.value = i;
}
