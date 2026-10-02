import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';

import 'providers/transaction_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transaction/transaction_screen.dart';
import 'screens/auth_gate.dart';

void main() async{
    
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();

    runApp(const ExpenseManagerApp(),);
}

class ExpenseManagerApp extends StatelessWidget {

  const ExpenseManagerApp({super.key,});

  @override
  Widget build(BuildContext context,) {

    return MultiProvider(
        providers:[
            ChangeNotifierProvider(create: (_)=>AuthProvider(),),
            ChangeNotifierProvider(create: (_)=>TransactionProvider(),),
        ], 
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expense Calculator',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo,),
                useMaterial3: true,
            ),
            home: const AuthGate(),
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