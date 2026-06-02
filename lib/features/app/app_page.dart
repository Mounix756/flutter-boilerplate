import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_boilerplate/features/home/pages/home_page.dart';
import 'package:flutter_boilerplate/features/profile/pages/profile_page.dart';
import 'package:flutter_boilerplate/shared/widgets/custom_app_bar.dart';

/// Shell principal du boilerplate.
///
/// Il reste volontairement léger: une page d'accueil de démonstration et une
/// page profil/préférences. Ajoutez vos modules métier dans `features/` puis
/// branchez-les ici.
class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final RxInt navIndex = Get.put(RxInt(0), tag: 'mainNavIndex');

  static const List<Widget> _screens = [
    HomePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is int && args >= 0 && args < _screens.length) {
      navIndex.value = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CustomAppBar.getSystemUiOverlayStyle(context),
      child: Scaffold(
        body: Obx(() => SafeArea(child: _screens[navIndex.value])),
        bottomNavigationBar: Obx(
          () => NavigationBar(
            selectedIndex: navIndex.value,
            onDestinationSelected: (index) => navIndex.value = index,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: 'home'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: 'profile'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
