import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/splash_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to enable/disable login button
    usernameController.addListener(_validateInputs);
    passwordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    usernameController.removeListener(_validateInputs);
    passwordController.removeListener(_validateInputs);
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isLoginEnabled = usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  Future<void> _handleLogin(
      AuthProvider authProvider, SplashProvider splashProvider) async {
    if (_isLoginEnabled) {
      await authProvider.login(
        usernameController.text,
        passwordController.text,
        context,
      );
      await splashProvider.setLoginStatus(true);

      if (authProvider.errorMessage.isNotEmpty && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text('Login Error'),
              ],
            ),
            content: Text(authProvider.errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final splashProvider = Provider.of<SplashProvider>(context);

    return Stack(
      children: [
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: 32),
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'புனித லூர்து மாதா ஜல்லிக்கட்டு பேரவை மாதாகோட்டை',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold, wordSpacing: 1),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  enabled: !authProvider.isLoading,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Username",
                    border: const OutlineInputBorder(),
                    fillColor: authProvider.isLoading ? Colors.grey[200] : null,
                    filled: authProvider.isLoading,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  enabled: !authProvider.isLoading,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    isDense: true,
                    border: const OutlineInputBorder(),
                    fillColor: authProvider.isLoading ? Colors.grey[200] : null,
                    filled: authProvider.isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) =>
                      _handleLogin(authProvider, splashProvider),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: (!_isLoginEnabled || authProvider.isLoading)
                      ? null
                      : () => _handleLogin(authProvider, splashProvider),
                  child:
                      Text(authProvider.isLoading ? "Logging in..." : "Login"),
                ),
              ],
            ),
          ),
        ),
        if (authProvider.isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Logging in...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while we verify your credentials',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
