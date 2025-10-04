import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final double totalBudget;
  final ValueChanged<double> onSetBudget;
  const BudgetCard({
    required this.totalBudget,
    required this.onSetBudget,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ...UI for budget card...
    return Container(
      // ...existing decoration and layout...
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_chart, color: Colors.lightBlue, size: 32),
              SizedBox(width: 12),
              Text(
                'Create Monthly Budget',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.attach_money, color: Colors.white),
            label: Text(
              'Set Budget',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              double? enteredBudget = await showDialog<double>(
                context: context,
                builder: (context) {
                  double tempBudget = totalBudget;
                  return AlertDialog(
                    title: const Text('Set Monthly Budget'),
                    content: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Enter budget amount'),
                      onChanged: (value) {
                        tempBudget = double.tryParse(value) ?? totalBudget;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, tempBudget),
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
              if (enteredBudget != null) {
                onSetBudget(enteredBudget);
              }
            },
          ),
        ],
      ),
    );
  }
}
