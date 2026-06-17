import 'package:flutter/material.dart';
import 'package:project2/herbalife/l10n/app_localizations.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/data/notifier.dart';
import 'package:project2/herbalife/public/page/info.dart';
import 'package:project2/herbalife/public/page/register.dart';
import 'package:project2/herbalife/public/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animController = controller;
    _fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<Authprovider>(context);
    final isKhmer = l10n.login != "Login";
    final dataProvider = Provider.of<SecureStorageProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF388E3C).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF81C784).withValues(alpha: 0.13),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF388E3C).withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnim ?? const AlwaysStoppedAnimation(1.0),
                  child: SlideTransition(
                    position:
                        _slideAnim ?? const AlwaysStoppedAnimation(Offset.zero),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Image.asset("assets/images/Herblogo.png", width: 180),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF388E3C,
                                ).withValues(alpha: 0.10),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: kPrimaryGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.login,
                                        style: isKhmer
                                            ? const TextStyle(
                                                fontFamily: 'KhmerFont',
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1B5E20),
                                              )
                                            : const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1B5E20),
                                                letterSpacing: -0.5,
                                              ),
                                      ),
                                      Text(
                                        'Welcome back!',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      l10n.id.contains("ID")
                                          ? "Member ID"
                                          : l10n.id,
                                      isKhmer,
                                    ),
                                    _buildField(
                                      controller: _idController,
                                      hint: l10n.id,
                                      icon: Icons.badge_outlined,
                                      isKhmer: isKhmer,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Fill in the ID';
                                        }
                                        if (int.tryParse(value!) == null) {
                                          return 'ID must be number';
                                        }

                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel(
                                      l10n.password.contains("Password")
                                          ? "Password"
                                          : l10n.password,
                                      isKhmer,
                                    ),
                                    const SizedBox(height: 6),
                                    //here
                                    TextFormField(
                                      controller: _passwordController,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Fill in the password';
                                        }
                                        return null;
                                      },
                                      obscureText: _obscurePassword,
                                      style: isKhmer
                                          ? const TextStyle(
                                              fontFamily: 'KhmerFont',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            )
                                          : const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      decoration: InputDecoration(
                                        hintText: l10n.password,
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 20,
                                          color: Color(0xFF43A047),
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF5FBF5),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 16,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFDCEEDC),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF43A047),
                                            width: 1.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ValueListenableBuilder(
                                  valueListenable: isId,
                                  builder: (context, value, child) {
                                    return ValueListenableBuilder(
                                      valueListenable: isUser,
                                      builder: (context, value, child) {
                                        return ElevatedButton(
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : () async {
                                                  if (!_formKey.currentState!
                                                      .validate()) {
                                                    return;
                                                  }
                                                  await authProvider.login(
                                                    _idController.text,
                                                    _passwordController.text,
                                                  );

                                                  if (authProvider.message !=
                                                      null) {
                                                    if (authProvider.message ==
                                                        "Login successful") {
                                                      // Save critical data to Secure Storage
                                                      await dataProvider
                                                          .writeSecureData(
                                                            'id',
                                                            authProvider.id!,
                                                          );
                                                      await dataProvider
                                                          .writeSecureData(
                                                            'userId',
                                                            authProvider
                                                                .userId!,
                                                          );
                                                      await dataProvider
                                                          .writeSecureData(
                                                            'token',
                                                            authProvider
                                                                .userToken!,
                                                          );
                                                      await dataProvider
                                                          .writeSecureData(
                                                            'refreshToken',
                                                            authProvider
                                                                .refreshToken!,
                                                          );
                                                      await dataProvider
                                                          .writeSecureData(
                                                            'password',
                                                            _passwordController
                                                                .text,
                                                          );

                                                      // Update global ValueNotifiers
                                                      isId.value =
                                                          authProvider.id!;
                                                      isUser.value =
                                                          authProvider.userId!;

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Info(
                                                                authProvider
                                                                    .userId,
                                                              ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  authProvider
                                                                      .message!,
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor:
                                                              Colors
                                                                  .red
                                                                  .shade700,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryGreen,
                                            disabledBackgroundColor:
                                                kPrimaryGreen.withValues(
                                                  alpha: 0.5,
                                                ),
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: authProvider.isLoading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : Text(
                                                  l10n.enter,
                                                  style: isKhmer
                                                      ? const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'KhmerFont',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )
                                                      : const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 0.3,
                                                        ),
                                                ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      "or",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Register(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF43A047),
                                      width: 1.8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    "Create an Account",
                                    style: TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isKhmer) {
    return Text(
      text,
      style: isKhmer
          ? const TextStyle(
              fontFamily: 'KhmerFont',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            )
          : const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
              letterSpacing: 0.2,
            ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isKhmer,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: isKhmer
          ? const TextStyle(
              fontFamily: 'KhmerFont',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )
          : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF43A047)),
        filled: true,
        fillColor: const Color(0xFFF5FBF5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCEEDC), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF43A047), width: 1.8),
        ),
      ),
    );
  }
}
