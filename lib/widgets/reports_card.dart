import 'package:flutter/material.dart';
import 'expense_pie_chart.dart';

class ReportsCard extends StatelessWidget {
  final Map<String, double> budgetInputs;
  const ReportsCard({Key? key, required this.budgetInputs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double totalSpent = budgetInputs.values.fold(0.0, (a, b) => a + b);
    final double totalBudget = budgetInputs.containsKey('Home rent') ? budgetInputs['Home rent']! : 0;
    final double remainingBudget = totalBudget - totalSpent;
    final double savings = remainingBudget > 0 ? remainingBudget : 0;

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, color: Colors.lightBlue, size: 32),
              SizedBox(width: 12),
              Text(
                'Reports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // Monthly Summary Section
          Card(
            color: Colors.black54,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  SizedBox(height: 8),
                  Text('Total Spent: ₩${totalSpent.toStringAsFixed(0)}', style: TextStyle(fontSize: 16)),
                  Text('Remaining Budget: ₩${remainingBudget.toStringAsFixed(0)}', style: TextStyle(fontSize: 16)),
                  Text('Savings: ₩${savings.toStringAsFixed(0)}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          Text(
            'View your monthly expense and budget analytics below.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: ExpensePieChart(dataMap: budgetInputs),
          ),
        ],
      ),
    );
  }
}
