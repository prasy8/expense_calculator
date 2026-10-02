import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/category_summary.dart';
import '../../widgets/expense_chart.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_card.dart';
import '../transaction/transaction_form_screen.dart';
import '../transaction/transaction_screen.dart';

import '../../models/transaction_model.dart';
import '../../widgets/banner_ad.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions(
            page: 1,
            limit: 5,
          );
    });

  }
  

  Future<void> _confirmDelete(TransactionModel transaction) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete ' '"${transaction.description}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    if (!mounted) return;

    final provider = context.read<TransactionProvider>();

    final success = await provider.deleteTransaction(
      id: transaction.id!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Transaction deleted successfully' : 'Failed to delete transaction',
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionProvider>(
        
        builder:
            (
              context,
              provider,
              child,
            ) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && provider.transactions.isEmpty) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        provider.loadTransactions(
                          page: 1,
                          limit: 5,
                        );
                      },

                      child:
                          const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return provider.loadTransactions(
                page: 1,
                limit: 5,
              );
            },

            child: CustomScrollView(
              slivers: [
                // =========================
                // APP BAR
                // =========================

                SliverAppBar(
                  floating: true,
                  pinned: true,

                  title: const Text('Spend Trace',),

                  actions: [
                    // =========================
                    // REFRESH
                    // =========================
                    IconButton(
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh,
                      ),

                      onPressed: () {
                        provider.loadTransactions(
                          page: 1,
                          limit: 5,
                        );
                      },
                    ),
                    // =========================
                    // LOGOUT
                    // =========================
                    IconButton(
                      tooltip: 'Logout',
                      icon: const Icon(
                        Icons.logout,
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );

                        if (!mounted) return;

                        if (shouldLogout != true) {
                          return;
                        }

                        final authProvider = context.read<AuthProvider>();
                        await authProvider.logout();

                      },
                    ),
                  ],
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Welcome, ${context.watch<AuthProvider>().user?.name ?? 'User'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // =========================
                // DASHBOARD CONTENT
                // =========================

                SliverPadding(
                  padding:
                      const EdgeInsets.all(16),

                  sliver: SliverList(
                    delegate:
                        SliverChildListDelegate(
                      [
                        // HEADER

                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Track your income and expenses',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // SUMMARY CARDS

                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 155,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),

                          children: [
                            SummaryCard(
                              title: 'Total Income',
                              amount: provider.summary.income,
                              icon: Icons.arrow_downward_rounded,
                              color: Colors.green,
                            ),

                            SummaryCard(
                              title: 'Total Expense',
                              amount: provider.summary.expense,
                              icon: Icons.arrow_upward_rounded,
                              color: Colors.red,
                            ),

                            SummaryCard(
                              title: 'Balance',
                              amount: provider.summary.balance,
                              icon: Icons.account_balance_wallet_outlined,
                              color: provider.summary.balance >= 0 ? Colors.blue : Colors.red,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // ADD BUTTON

                        SizedBox(
                          width: double.infinity,

                          child:
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionFormScreen(),
                                ),
                              );

                              if (result == true) {
                                await provider.loadTransactions(
                                  page: 1,
                                  limit: 5,
                                );
                              }
                            },

                            icon:
                                const Icon(
                              Icons.add,
                            ),

                            label:
                                const Text(
                              'Add Transaction',
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // RECENT TRANSACTIONS

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [
                            const Text(
                              'Recent Transactions',

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TransactionScreen(),
                                  ),
                                );
                              },

                              child:
                                  const Text(
                                'View All',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        if (provider.transactions.isEmpty)
                          const Center(
                            child:
                                Padding(
                                  padding:
                                      EdgeInsets.all(
                                        30,
                                      ),

                                  child:
                                      Text(
                                        'No transactions found.',
                                      ),
                                ),
                          )
                        else
                          ...provider.transactions.map(
                            (transaction) {
                              return TransactionCard(
                                transaction: transaction,
                                onEdit: () async {
                                  final result = await Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionFormScreen(
                                            transaction: transaction,
                                          ),
                                    ),
                                  );

                                  if (result == true) {
                                    await provider.loadTransactions(
                                      page: 1,
                                      limit: 5,
                                    );
                                  }
                                },
                                onDelete: () {
                                  _confirmDelete(transaction);
                                },
                              );
                            },
                          ),

                        const SizedBox(
                          height: 30,
                        ),

                        // CATEGORY SUMMARY

                        const Text(
                          'Expense by Category',

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),

                            child:
                                CategorySummary(
                                  categorySummary: provider.categorySummary,
                                ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // EXPENSE CHART

                        const Text(
                          'Expense Chart',

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),

                            child:
                                ExpenseChart(
                                  categorySummary:
                                      provider.categorySummary,
                                ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                // =========================
                // ADMOB BANNER
                // =========================

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Center(
                      child: BannerAdWidget(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}