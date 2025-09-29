import 'package:flutter/material.dart';
import 'widgets/budget_card.dart';
import 'widgets/plan_card.dart';
import 'widgets/pay_card.dart';
import 'widgets/reports_card.dart';

class HusbandPage extends StatelessWidget {
  final String name;
  const HusbandPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return _HusbandPageContent(name: name);
  }
}

class _HusbandPageContent extends StatefulWidget {
  final String name;
  const _HusbandPageContent({required this.name});

  @override
  State<_HusbandPageContent> createState() => _HusbandPageContentState();
}

class _HusbandPageContentState extends State<_HusbandPageContent> {
  double _walletAmount = 100000;
  double _totalBudget = 0;
  int _selectedIndex = 0;
  Map<String, double> _budgetInputs = {
    'Home rent': 0,
    'Electric': 0,
    'Water': 0,
    'Internet': 0,
    'Bill': 0,
    'Others': 0,
  };

  // ...existing dialog and logic methods...

  Widget _buildCardContent() {
    switch (_selectedIndex) {
      case 0:
        return BudgetCard(
          totalBudget: _totalBudget,
          onSetBudget: (amount) {
            setState(() {
              _totalBudget = amount;
              _walletAmount -= amount;
            });
          },
        );
      case 1:
        return PlanCard(
          budgetInputs: _budgetInputs,
          onPlanBudget: (inputs) {
            setState(() {
              _budgetInputs = inputs;
            });
          },
        );
      case 2:
        return PayCard(
          walletAmount: _walletAmount,
          budgetInputs: _budgetInputs,
          onPayExpense: (key, value) {
            setState(() {
              if (_walletAmount >= value) {
                _walletAmount -= value;
                _budgetInputs[key] = 0;
              }
            });
          },
        );
      case 3:
        return ReportsCard();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Profile'),
                    content: Text('Logged in as ${widget.name}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.deepPurple),
                  ),
                  SizedBox(width: 12),
                  Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
                  SizedBox(width: 6),
                  Text(
                    _totalBudget > 0
                        ? '₩${_totalBudget.toStringAsFixed(0)}'
                        : 'Wallet',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Center(child: _buildCardContent()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pay'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
