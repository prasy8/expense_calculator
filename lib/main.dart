import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transaction/transaction_screen.dart';

void main() {
  runApp(
    const ExpenseManagerApp(),
  );
}

class ExpenseManagerApp extends StatelessWidget {

  const ExpenseManagerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context,) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),

      child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Expense Manager',
              theme: AppTheme.lightTheme,
              home: const MainNavigation(),
            ),
    );
  }
}

class MainNavigation extends StatefulWidget {

  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    //TransactionsScreen(),
    TransactionScreen(),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            currentIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}