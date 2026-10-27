import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../portfolio/views/portfolio_view.dart';
import '../../profile/views/profile_view.dart';
import '../../services/views/services_view.dart';
import '../controllers/main_controller.dart';
import 'home_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const _tabs = <Widget>[HomeView(), ServicesView(), PortfolioView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.index.value == MainController.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.changeTab(MainController.home);
        },
        child: Scaffold(
          body: IndexedStack(index: controller.index.value, children: _tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.index.value,
            onDestinationSelected: controller.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Services',
              ),
              NavigationDestination(
                icon: Icon(Icons.workspace_premium_outlined),
                selectedIcon: Icon(Icons.workspace_premium_rounded),
                label: 'Our work',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
