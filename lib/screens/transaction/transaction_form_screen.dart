import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
final TransactionModel? transaction;

const TransactionFormScreen({
super.key,
this.transaction,
});

bool get isEditing => transaction != null;

@override
State<TransactionFormScreen> createState() =>
_TransactionFormScreenState();
}

class _TransactionFormScreenState
extends State<TransactionFormScreen> {

final _formKey = GlobalKey<FormState>();

final TextEditingController _descriptionController =
TextEditingController();

final TextEditingController _amountController =
TextEditingController();

String _type = 'expense';

String _category = '';

DateTime _selectedDate = DateTime.now();

bool _isSaving = false;

final List<String> _incomeCategories = [
'Salary',
'Business',
'Investment',
'Interest',
'Gift',
'Other',
];

final List<String> _expenseCategories = [
'Food',
'Shopping',
'Transport',
'Bills',
'Entertainment',
'Health',
'Education',
'Travel',
'Rent',
'Other',
];

List<String> get _categories {
if (_type == 'income') {
return _incomeCategories;
}


return _expenseCategories;

}

@override
void initState() {
super.initState();


if (widget.transaction != null) {
  final transaction = widget.transaction!;

  _descriptionController.text =
      transaction.description;

  _amountController.text =
      transaction.amount.toStringAsFixed(2);

  _type = transaction.type;

  _category = transaction.category;

  _selectedDate =
      transaction.transactionDate;

  if (!_categories.contains(_category)) {
    _category = '';
  }
}


}

@override
void dispose() {
_descriptionController.dispose();
_amountController.dispose();


super.dispose();


}

Future<void> _selectDate() async {
final DateTime? picked =
await showDatePicker(
context: context,


  initialDate: _selectedDate,

  firstDate: DateTime(2000),

  lastDate: DateTime(2100),
);

if (picked != null) {
  setState(() {
    _selectedDate = picked;
  });
}


}

Future<void> _saveTransaction() async {
if (!_formKey.currentState!.validate()) {
return;
}


if (_category.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please select a category.',
      ),
    ),
  );

  return;
}

final amount =
    double.tryParse(
  _amountController.text.trim(),
);

if (amount == null || amount <= 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please enter a valid amount.',
      ),
    ),
  );

  return;
}

setState(() {
  _isSaving = true;
});

final provider =
    context.read<TransactionProvider>();

final date =
    DateFormat('yyyy-MM-dd')
        .format(_selectedDate);

bool success;

if (widget.isEditing) {
  success = await provider.updateTransaction(
    id: widget.transaction!.id!,
    description: _descriptionController.text.trim(),
    amount: amount,
    type: _type,
    category: _category,
    date: date,
  );
} else {
  success = await provider.addTransaction(
    description: _descriptionController.text.trim(),
    amount: amount,
    type: _type,
    category: _category,
    date: date,
  );
}

if (!mounted) {
  return;
}

setState(() {
  _isSaving = false;
});

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        widget.isEditing
            ? 'Transaction updated successfully.'
            : 'Transaction added successfully.',
      ),
    ),
  );

  Navigator.pop(context, true);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        provider.errorMessage ??
            'Something went wrong.',
      ),
    ),
  );
}


}

@override
Widget build(BuildContext context) {
final bool isEditing = widget.isEditing;


return Scaffold(
  appBar: AppBar(
    title: Text(
      isEditing
          ? 'Edit Transaction'
          : 'Add Transaction',
    ),
  ),

  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =========================
            // PAGE TITLE
            // =========================

            Text(
              isEditing
                  ? 'Update Transaction'
                  : 'New Transaction',

              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              isEditing
                  ? 'Modify your transaction details'
                  : 'Enter your income or expense details',

              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 28),

            // =========================
            // DESCRIPTION
            // =========================

            TextFormField(
              controller:
                  _descriptionController,

              textInputAction:
                  TextInputAction.next,

              decoration:
                  const InputDecoration(
                labelText: 'Description',
                hintText:
                    'e.g. Salary, Grocery, Rent',
                prefixIcon:
                    Icon(Icons.description_outlined),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter description.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // AMOUNT
            // =========================

            TextFormField(
              controller:
                  _amountController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              textInputAction:
                  TextInputAction.next,

              decoration:
                  const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixText: '₹ ',
                prefixIcon:
                    Icon(Icons.currency_rupee),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter amount.';
                }

                final amount =
                    double.tryParse(
                  value.trim(),
                );

                if (amount == null ||
                    amount <= 0) {
                  return 'Enter a valid amount.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // TYPE
            // =========================

            const Text(
              'Transaction Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(
                    Icons.arrow_upward,
                  ),
                ),

                ButtonSegment<String>(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(
                    Icons.arrow_downward,
                  ),
                ),
              ],

              selected: {_type},

              onSelectionChanged:
                  (Set<String> selection) {
                setState(() {
                  _type =
                      selection.first;

                  _category = '';
                });
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // CATEGORY
            // =========================

            DropdownButtonFormField<String>(
              initialValue:
                  _category.isEmpty
                      ? null
                      : _category,

              decoration:
                  const InputDecoration(
                labelText: 'Category',
                prefixIcon:
                    Icon(Icons.category_outlined),
              ),

              items:
                  _categories.map(
                (category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),

              onChanged: (value) {
                setState(() {
                  _category =
                      value ?? '';
                });
              },

              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Please select category.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // DATE
            // =========================

            InkWell(
              onTap: _selectDate,

              borderRadius:
                  BorderRadius.circular(12),

              child: InputDecorator(
                decoration:
                    const InputDecoration(
                  labelText: 'Date',
                  prefixIcon:
                      Icon(Icons.calendar_month),
                ),

                child: Text(
                  DateFormat(
                    'dd MMMM yyyy',
                  ).format(_selectedDate),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =========================
            // SAVE BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed:
                    _isSaving
                        ? null
                        : _saveTransaction,

                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isEditing
                            ? Icons.save_outlined
                            : Icons.add,
                      ),

                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : isEditing
                          ? 'Update Transaction'
                          : 'Add Transaction',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // CANCEL
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: OutlinedButton(
                onPressed:
                    _isSaving
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                            );
                          },

                child:
                    const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);


}
}
