import 'package:flutter/material.dart';
import 'husband_page.dart';
import 'services_admin_page.dart';
import 'admin_dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('App started and Firebase initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Expenses App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String? _error;
  bool _usePhone = false;
  String? _verificationId;

  // Example admin email list (replace with Firestore or custom claims for production)
  final List<String> _adminEmails = [
    'mutanaafis@gmail.com',
    'alaale123@gmail.com', // Add your admin email(s) here
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          // Login/Register screen with phone/email toggle
          return Scaffold(
            appBar: AppBar(title: Text('Login/Register')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Email'),
                        selected: !_usePhone,
                        onSelected: (v) => setState(() => _usePhone = false),
                      ),
                      SizedBox(width: 12),
                      ChoiceChip(
                        label: Text('Phone'),
                        selected: _usePhone,
                        onSelected: (v) => setState(() => _usePhone = true),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (!_usePhone) ...[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      child: Text('Login'),
                      onPressed: () async {
                        setState(() => _error = null);
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                        } catch (e) {
                          setState(() => _error = e.toString());
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      child: Text('Register'),
                      onPressed: () async {
                        setState(() => _error = null);
                        try {
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                        } catch (e) {
                          setState(() => _error = e.toString());
                        }
                      },
                    ),
                  ] else ...[
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone (+1234567890)'),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Send Code'),
                      onPressed: () async {
                        setState(() => _error = null);
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: _phoneController.text.trim(),
                          verificationCompleted: (PhoneAuthCredential credential) async {
                            await FirebaseAuth.instance.signInWithCredential(credential);
                          },
                          verificationFailed: (e) {
                            setState(() => _error = e.toString());
                          },
                          codeSent: (verificationId, resendToken) {
                            setState(() => _verificationId = verificationId);
                          },
                          codeAutoRetrievalTimeout: (verificationId) {
                            setState(() => _verificationId = verificationId);
                          },
                        );
                      },
                    ),
                    if (_verificationId != null) ...[
                      SizedBox(height: 16),
                      TextField(
                        controller: _smsController,
                        decoration: InputDecoration(labelText: 'SMS Code'),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        child: Text('Verify & Login'),
                        onPressed: () async {
                          setState(() => _error = null);
                          try {
                            final credential = PhoneAuthProvider.credential(
                              verificationId: _verificationId!,
                              smsCode: _smsController.text.trim(),
                            );
                            await FirebaseAuth.instance.signInWithCredential(credential);
                          } catch (e) {
                            setState(() => _error = e.toString());
                          }
                        },
                      ),
                    ],
                  ],
                  if (_error != null) ...[
                    SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          );
        } else {
          // Role-based navigation
          final isAdmin = _adminEmails.contains(user.email);
          return Scaffold(
            appBar: AppBar(
              title: Text(isAdmin ? 'Admin Dashboard' : 'Home Expenses App'),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
      body: isAdmin
        ? AdminDashboardPage()
        : HusbandPage(name: user.displayName ?? user.email ?? user.phoneNumber ?? 'User'),
          );
        }
      },
    );
  }
}
