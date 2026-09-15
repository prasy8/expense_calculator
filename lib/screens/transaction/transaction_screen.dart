import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_card.dart';
import 'transaction_form_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
                    });

                    _loadTransactions();
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
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
                                            );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}