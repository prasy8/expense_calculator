import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_card.dart';
import 'transaction_form_screen.dart';

import '../../models/transaction_model.dart';
import '../../services/transaction_api_service.dart';
import '../../utils/csv_export.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    super.key,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  final TextEditingController _searchController = TextEditingController();

  String _selectedType = '';
  String _selectedMonth = '';
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions(
        page: 1,
        limit: 10,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    /*
    print('----------------------------');
    print('Selected Type: $_selectedType');
    print('Search: ${_searchController.text.trim()}');
    print('Calling API...');
    print('----------------------------');
    */
    context.read<TransactionProvider>().loadTransactions(
      page: 1,
      limit: 10,
      search: _searchController.text.trim(),
      type: _selectedType,
      month: _selectedMonth,
      category: _selectedCategory,
    );
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
      page: provider.pagination.currentPage,
      limit: 10,
      search: _searchController.text.trim(),
      type: _selectedType,
      month: _selectedMonth,
      category: _selectedCategory,
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
  void _loadPage(int page) {
    final provider = context.read<TransactionProvider>();

    provider.loadTransactions(
      page: page,
      limit: 10,
      search: _searchController.text.trim(),
      type: _selectedType,
      month: _selectedMonth,
      category: _selectedCategory,
    );
  }

  Future<void> _exportCsv() async {
    //print('exort csv function called');
    
    try {
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing CSV...'),
        ),
      );

      final apiService = TransactionApiService();

      // Get ALL transactions using current filters
      final transactions = await apiService.getAllTransactionsForExport(
        search: _searchController.text.trim(),
        type: _selectedType,
        month: _selectedMonth,
        category: _selectedCategory,
      );

      if (!mounted) return;

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No transactions found to export.'),
          ),
        );
        return;
      }

      // Create and share CSV
      await CsvExport.exportTransactions(
        transactions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${transactions.length} transactions exported successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CSV export failed: $e',
          ),
        ),
      );
    }
    // hide loading
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 28,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
                    IconButton(
                      tooltip: 'Export CSV', 
                      onPressed: _exportCsv, 
                      icon: const Icon(Icons.download))
                ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );

          if (result == true) {
            _loadTransactions();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),

      body: Consumer<TransactionProvider>(
        builder: (
          context,
          provider,
          child,
        ) {

          return RefreshIndicator(
            onRefresh: () async {
              _loadTransactions();
            },

            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // =========================
                // PAGE TITLE
                // =========================

                const Text(
                  'All Transactions',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Manage your income and expenses',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),
                
                // =========================
                // SUMMARY CARDS
                // =========================

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _summaryCard(
                      title: 'Income',
                      amount: provider.summary.income,
                      icon: Icons.arrow_downward,
                      iconColor: Colors.green,
                    ),

                    _summaryCard(
                      title: 'Expenses',
                      amount: provider.summary.expense,
                      icon: Icons.arrow_upward,
                      iconColor: Colors.red,
                    ),

                    _summaryCard(
                      title: 'Balance',
                      amount: provider.summary.balance,
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // =========================
                // SEARCH
                // =========================

                TextField(
                  controller: _searchController,
                  onSubmitted: (_) {
                    _loadTransactions();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadTransactions();
                                  setState(() {});
                                },
                              )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // TYPE FILTER
                // =========================

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: '',
                      label: Text('All'),
                    ),
                    ButtonSegment<String>(
                      value: 'income',
                      label: Text('Income'),
                    ),
                    ButtonSegment<String>(
                      value: 'expense',
                      label: Text('Expense'),
                    ),
                  ],

                  selected: {
                    _selectedType,
                  },

                  onSelectionChanged: (
                    Set<String> selected,
                  ) {
                    setState(() {
                      _selectedType = selected.first;
                      // Clear category when transaction type changes
                      _selectedCategory = '';
                    });

                    _loadTransactions();
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: 'Month',
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('All Months'),
                    ),
                    DropdownMenuItem(
                      value: '2026-01',
                      child: Text('January 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-02',
                      child: Text('February 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-03',
                      child: Text('March 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-04',
                      child: Text('April 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-05',
                      child: Text('May 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-06',
                      child: Text('June 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-07',
                      child: Text('July 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-08',
                      child: Text('August 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-09',
                      child: Text('September 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-10',
                      child: Text('October 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-11',
                      child: Text('November 2026'),
                    ),
                    DropdownMenuItem(
                      value: '2026-12',
                      child: Text('December 2026'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value ?? '';
                      // Clear category because available categories may change
                      _selectedCategory = '';
                    });

                    _loadTransactions();
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: provider.categoryOptions.contains(_selectedCategory) ? _selectedCategory : null,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All Categories'),
                    ),
                    /*
                    ...provider.categorySummary.keys.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                    */
                    ...provider.categoryOptions.map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? '';
                    });

                    _loadTransactions();
                  },
                ),

                const SizedBox(height: 24),

                // =========================
                // LOADING
                // =========================

                if (provider.isLoading &&
                    provider.transactions.isEmpty)

                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child:
                          CircularProgressIndicator(),
                    ),
                  )

                // =========================
                // ERROR
                // =========================

                else if (
                  provider.errorMessage != null &&
                  provider.transactions.isEmpty
                )

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [

                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: _loadTransactions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )

                // =========================
                // EMPTY
                // =========================

                else if (
                  provider.transactions.isEmpty
                )

                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No transactions found.',
                      ),
                    ),
                  )

                // =========================
                // TRANSACTION LIST
                // =========================

                else
                  ...[
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
                                                                                                        transaction:
                                                                                                            transaction,
                                                                                                      ),
                                                                                                    ),
                                                                                                  );

                                                                    if (result == true) {
                                                                      _loadTransactions();
                                                                    }
                                                  },
                                                  onDelete: () {
                                                    _confirmDelete(transaction);
                                                  },
                                                );
                        },
                      ),
                      // =========================
                      // Loading indicator
                      // =========================
                      if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      // =========================
                      // PAGINATION
                      // =========================

                      if (provider.pagination.totalPages > 0) ...[
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Previous page',
                              onPressed: provider.pagination.currentPage > 1
                                  ? () {
                                      _loadPage(
                                        provider.pagination.currentPage - 1,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),

                            Text(
                              'Page ${provider.pagination.currentPage} '
                              'of ${provider.pagination.totalPages}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              tooltip: 'Next page',
                              onPressed: provider.pagination.currentPage <
                                      provider.pagination.totalPages
                                  ? () {
                                      _loadPage(
                                        provider.pagination.currentPage + 1,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Showing ${provider.pagination.from}–'
                          '${provider.pagination.to} of '
                          '${provider.pagination.totalRecords} transactions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),

                      ],
                  ],
                
              ],
            ),
            
            

          );
        },
      ),
    );
  }
}