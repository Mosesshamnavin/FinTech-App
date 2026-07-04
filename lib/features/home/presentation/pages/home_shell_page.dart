import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vasooldrive/core/services/app_localization.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final bool isMainPage = location == '/collections' ||
                            location == '/expenses' ||
                            location == '/customers' ||
                            location == '/reports' ||
                            location == '/settings';

    return ValueListenableBuilder<String>(
      valueListenable: AppLocalization.languageNotifier,
      builder: (context, language, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Exit App'.tr()),
                  content: Text('Are you sure you want to exit the application?'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('CANCEL'.tr()),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text('EXIT'.tr()),
                    ),
                  ],
                );
              },
            );
            if (shouldPop == true) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            body: navigationShell,
            bottomNavigationBar: isMainPage
                ? BottomNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    type: BottomNavigationBarType.fixed,
                    onTap: (index) {
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: FaIcon(FontAwesomeIcons.moneyBill1Wave, size: 20),
                        ),
                        label: 'Collection'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: FaIcon(FontAwesomeIcons.solidCreditCard, size: 20),
                        ),
                        label: 'Expense'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: FaIcon(FontAwesomeIcons.users, size: 20),
                        ),
                        label: 'Customer'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: FaIcon(FontAwesomeIcons.chartSimple, size: 20),
                        ),
                        label: 'Reports'.tr(),
                      ),
                      BottomNavigationBarItem(
                        icon: const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: FaIcon(FontAwesomeIcons.gear, size: 20),
                        ),
                        label: 'Settings'.tr(),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
