import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apartmate/core/utils/validators.dart';
import 'package:apartmate/core/utils/app_snackbar.dart';
import 'package:apartmate/data/models/society_model.dart';
import 'package:apartmate/domain/repositories/i_auth_repository.dart';
import 'package:apartmate/domain/repositories/i_society_repository.dart';
import 'package:apartmate/routes/app_routes.dart';

class AuthController extends GetxController {
  final IAuthRepository _authRepository;
  AuthController(this._authRepository);

  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final isPasswordVisible = false.obs;

  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final signupPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isSignupPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isResettingPassword = false.obs;

  final isLoading = false.obs;
  final loginShakeTrigger = 0.obs;
  final loginError = RxnString();

  final signupShakeTrigger = 0.obs;
  final emailError = RxnString();
  final phoneError = RxnString();

  @override
  void onInit() {
    super.onInit();
    emailCtrl.addListener(() => emailError.value = null);
    phoneCtrl.addListener(() => phoneError.value = null);
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleSignupPasswordVisibility() => isSignupPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  /// Shared post-auth routing:
  /// new user → Signup
  /// incomplete signup (no phone) → Signup
  /// no society → Society Register
  /// not approved → Registration Status
  /// approved + no buildings → Society Buildings
  /// approved + buildings → Dashboard
  Future<void> _navigateAfterAuth({bool isNewUser = false}) async {
    if (isNewUser) {
      Get.offAllNamed(AppRoutes.signup);
      return;
    }

    try {
      final user = _authRepository.currentUser;

      // Signup data incomplete → finish Signup first
      final hasSignupData = user != null &&
          user.fullName.trim().isNotEmpty &&
          user.phone.trim().isNotEmpty;

      if (!hasSignupData) {
        Get.offAllNamed(AppRoutes.signup);
        return;
      }

      final society = await Get.find<ISocietyRepository>().getCurrentSociety();

      if (society == null) {
        Get.offAllNamed(AppRoutes.societyRegister);
        return;
      }

      if (society.registrationStatus != SocietyRegistrationStatus.approved) {
        Get.offAllNamed(AppRoutes.registrationStatus);
        return;
      }

      final buildings = await Get.find<ISocietyRepository>().getBuildings();
      if (buildings.isEmpty) {
        Get.offAllNamed(AppRoutes.societyBuildings);
        return;
      }

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (_) {
      Get.offAllNamed(AppRoutes.registrationStatus);
    }
  }

  Future<void> login() async {
    if (usernameCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
      loginError.value = 'Please enter your username and password';
      loginShakeTrigger.value++;
      return;
    }
    isLoading.value = true;
    try {
      await _authRepository.login(
        username: usernameCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      loginError.value = null;
      await _navigateAfterAuth();
    } catch (_) {
      loginError.value = 'Incorrect username or password';
      loginShakeTrigger.value++;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authRepository.loginWithGoogle();
      await _navigateAfterAuth(isNewUser: result.isNewUser);
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'aborted-by-user') return;
      AppSnackbar.error('Google sign-in failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    try {
      await _authRepository.loginWithApple();
      await _navigateAfterAuth();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authRepository.loginWithGoogle();
      await _navigateAfterAuth(isNewUser: result.isNewUser);
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('aborted-by-user') &&
          !msg.contains('canceled') &&
          !msg.contains('cancelled')) {
        AppSnackbar.error('Google sign-in failed', 'Please try again');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithApple() async {
    isLoading.value = true;
    try {
      await _authRepository.loginWithApple();
      await _navigateAfterAuth();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final resetEmailCtrl = TextEditingController(text: usernameCtrl.text.trim());
    final result = await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reset password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the email for your account. We\'ll send a reset link.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@gmail.com',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: resetEmailCtrl.text.trim()),
                  child: const Text('Send reset link'),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    isResettingPassword.value = true;
    try {
      await _authRepository.sendPasswordResetEmail(result);
      AppSnackbar.success(
        'Email sent',
        'Check $result for a password reset link',
      );
    } catch (e) {
      AppSnackbar.error('Reset failed', e.toString());
    } finally {
      isResettingPassword.value = false;
    }
  }

  Future<void> signUp() async {
    if (fullNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        signupPasswordCtrl.text.isEmpty) {
      signupShakeTrigger.value++;
      AppSnackbar.error('Missing info', 'Please fill in all required fields');
      return;
    }
    if (!Validators.isValidEmail(emailCtrl.text)) {
      emailError.value = 'Enter a valid email address';
      return;
    }
    if (!Validators.isValidPhone(phoneCtrl.text)) {
      phoneError.value = 'Use format 03XXXXXXXXX or +92 3XX XXXXXXX';
      return;
    }
    if (signupPasswordCtrl.text != confirmPasswordCtrl.text) {
      AppSnackbar.error('Password mismatch', 'Passwords do not match');
      return;
    }
    final passwordError =
        Validators.passwordErrorMessage(signupPasswordCtrl.text);
    if (passwordError != null) {
      AppSnackbar.error('Weak password', passwordError);
      return;
    }

    isLoading.value = true;
    try {
      // If already signed in with Google, only complete profile
      final existing = _authRepository.currentUser;
      if (existing != null) {
        await _authRepository.updateProfile(
          existing.copyWith(
            fullName: fullNameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
          ),
        );
      } else {
        await _authRepository.signUp(
          fullName: fullNameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          password: signupPasswordCtrl.text,
        );
      }

      // After signup data is saved → Society Register
      Get.offAllNamed(AppRoutes.societyRegister);
    } catch (e) {
      AppSnackbar.error('Sign up failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignup() => Get.toNamed(AppRoutes.signup);
  void goToLogin() => Get.back();

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    signupPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}