import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_router.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRouter.notifications)) return 2;
    if (location.startsWith(AppRouter.profile)) return 1;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
      case 1:
        context.go(AppRouter.profile);
      case 2:
        context.go(AppRouter.notifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, notifState) {
            final unread = notifState is NotificationsLoaded
                ? notifState.unreadCount
                : 0;
            return BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) => _onTabTapped(context, i),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread > 9 ? '9+' : unread.toString()),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread > 9 ? '9+' : unread.toString()),
                    child: const Icon(Icons.notifications),
                  ),
                  label: 'Notifications',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
