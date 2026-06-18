import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/page/register2.dart';
import 'package:project2/herbalife/public/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addresssController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _image = photo;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Photo selected successfully!',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addresssController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Authprovider>(context);

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
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnim ?? const AlwaysStoppedAnimation(1.0),
                  child: SlideTransition(
                    position: _slideAnim ?? const AlwaysStoppedAnimation(Offset.zero),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        Image.asset("assets/images/Herblogo.png", width: 180),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF388E3C).withValues(alpha: 0.10),
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
                                  Container(width: 5, height: 32, decoration: BoxDecoration(color: kPrimaryGreen, borderRadius: BorderRadius.circular(4))),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20), letterSpacing: -0.5)),
                                      Text('Join Herbalife today', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Center(
                                child: GestureDetector(
                                  onTap: _pickPhoto,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFE8F5E9),
                                          border: Border.all(color: kPrimaryGreen.withValues(alpha: 0.3), width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF388E3C).withValues(alpha: 0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          image: _image != null
                                              ? DecorationImage(
                                                  image: kIsWeb 
                                                      ? NetworkImage(_image!.path) 
                                                      : FileImage(io.File(_image!.path)) as ImageProvider,
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: _image == null
                                            ? Icon(Icons.person_rounded, size: 42, color: kPrimaryGreen.withValues(alpha: 0.5))
                                            : null,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _image == null ? 'Tap to add photo' : 'Photo selected ✓',
                                    style: TextStyle(fontSize: 12, color: _image == null ? Colors.grey.shade400 : const Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Full Name'),
                                    const SizedBox(height: 6),
                                    _buildField(controller: nameController, hint: 'Enter your full name', icon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Please enter name' : null),
                                    const SizedBox(height: 16),
                                    _buildLabel('Address'),
                                    const SizedBox(height: 6),
                                    _buildField(controller: addresssController, hint: 'Enter your address', icon: Icons.location_on_outlined, validator: (v) => v!.isEmpty ? 'Please enter address' : null),
                                    const SizedBox(height: 16),
                                    _buildLabel('Phone Number'),
                                    const SizedBox(height: 6),
                                    _buildField(controller: phoneController, hint: 'Enter your phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Please enter phone' : null),
                                    const SizedBox(height: 16),
                                    _buildLabel('Email Address'),
                                    const SizedBox(height: 6),
                                    _buildField(controller: emailController, hint: 'Enter your email', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
                                    const SizedBox(height: 28),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : () async {
                                    if (_image == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a photo'), backgroundColor: Colors.red));
                                      return;
                                    }
                                    if (!_formKey.currentState!.validate()) return;
                                    await authProvider.register(nameController.text, addresssController.text, phoneController.text, emailController.text, _image!);
                                    if (authProvider.message == "successfully") {
                                      if (!mounted) return;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          title: const Text("Success!"),
                                          content: const Text("Your account has been created successfully."),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Register2())),
                                              child: const Text("Continue"),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.message ?? 'Error'), backgroundColor: Colors.red));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  child: authProvider.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)));

  Widget _buildField({required TextEditingController controller, required String hint, required IconData icon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF43A047)),
        filled: true,
        fillColor: const Color(0xFFF5FBF5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCEEDC))),
      ),
    );
  }
}
