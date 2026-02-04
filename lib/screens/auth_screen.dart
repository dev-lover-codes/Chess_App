import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_auth_service.dart';
import '../providers/stage_provider.dart';
import 'stage_selection_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;

  const AuthScreen({super.key, required this.isSignUp});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late bool _isSignUp;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = LocalAuthService();

    try {
      Map<String, dynamic> result;
      
      if (_isSignUp) {
        // Sign Up
        result = await authService.signUp(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Account created!'),
                backgroundColor: Colors.green,
              ),
            );
            // Switch to sign in
            setState(() => _isSignUp = false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Sign up failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Sign In
        result = await authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          if (result['success'] == true) {
            // Success! Load user progress
            await _loadUserProgress();
            
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StageSelectionScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Sign in failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadUserProgress() async {
    final authService = LocalAuthService();
    final data = await authService.loadProgress();
    
    if (data != null && mounted) {
      final stageProvider = Provider.of<StageProvider>(context, listen: false);
      
      // Update provider with local data
      if (data['completedStage'] != null) {
        stageProvider.syncFromCloud(data['completedStage']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Create Account' : 'Welcome Back'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Icon
              Icon(
                _isSignUp ? Icons.person_add : Icons.login,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.length < 6 ? 'Password must be 6+ chars' : null,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              
              const SizedBox(height: 16),
              
              // Toggle Mode
              TextButton(
                onPressed: () {
                  setState(() => _isSignUp = !_isSignUp);
                },
                child: Text(_isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up'),
              ),
              
              if (!_isSignUp) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    // Placeholder for invite functionality
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard! Share with friends.')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Invite a Friend'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
