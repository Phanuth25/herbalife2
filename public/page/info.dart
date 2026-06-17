import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/page/login.dart';
import 'package:project2/herbalife/public/page/product.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:provider/provider.dart';

class Info extends StatefulWidget {
  final String? userId;

  const Info(this.userId, {super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> with SingleTickerProviderStateMixin {
  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;
  File? _image;
  final ImagePicker _picker = ImagePicker();

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().getProfile();
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));

      if (!mounted) return; // ✅ check before using context
      await context.read<ProfileProvider>().updateProfile(_image!);

      if (!mounted) return; // ✅ check again before showing snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo updated successfully!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  DecorationImage? _buildProfileImage(String? imageUrl) {
    if (_image != null) {
      return DecorationImage(fit: BoxFit.cover, image: FileImage(_image!));
    }
    if (imageUrl != null) {
      return DecorationImage(fit: BoxFit.cover, image: NetworkImage(imageUrl));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final dataProvider = Provider.of<SecureStorageProvider>(context);
    final imageUrl = profileProvider.photo;
    final profileImage = _buildProfileImage(imageUrl);
    final showFallbackIcon = profileImage == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Stack(
        children: [
          // ── decorative circles ───────────────────────────────────────
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
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF388E3C).withValues(alpha: 0.07),
              ),
            ),
          ),

          // ── main content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── custom app bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Herbalife",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: kPrimaryGreen,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF388E3C,
                              ).withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 16,
                              color: Color(0xFF43A047),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${profileProvider.ispoint}pt",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 1,
                              height: 14,
                              color: const Color(0xFFDCEEDC),
                            ),
                            const Icon(
                              Icons.local_offer_rounded,
                              size: 15,
                              color: Color(0xFF43A047),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${profileProvider.isdiscount}% off",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── body ────────────────────────────────────────────────
                Expanded(
                  child: profileProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF43A047),
                            strokeWidth: 2.5,
                          ),
                        )
                      : FadeTransition(
                          opacity:
                              _fadeAnim ?? const AlwaysStoppedAnimation(1.0),
                          child: SlideTransition(
                            position:
                                _slideAnim ??
                                const AlwaysStoppedAnimation(Offset.zero),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                              child: Column(
                                children: [
                                  // hero image
                                  Stack(
                                    children: [
                                      // photo avatar
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            _pickPhoto();
                                          },
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Container(
                                                width: 180,
                                                height: 180,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(
                                                    0xFFE8F5E9,
                                                  ),
                                                  border: Border.all(
                                                    color: kPrimaryGreen
                                                        .withValues(alpha: 0.3),
                                                    width: 3,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF388E3C,
                                                      ).withValues(alpha: 0.15),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                  image: profileImage,
                                                ),

                                                // here
                                                child: showFallbackIcon
                                                    ? Opacity(
                                                        opacity: 0,
                                                      child: Icon(
                                                          Icons.person_rounded,
                                                          size: 42,
                                                          color: kPrimaryGreen
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                        ),
                                                    )
                                                    : null,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: kPrimaryGreen,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        child: InkWell(
                                          onTap: () {},
                                          child: const Icon(
                                            Icons.change_circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // greeting
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Hello, ',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${profileProvider.isname}!',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1B5E20),
                                              fontFamily: 'KhmerFont',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // success message
                                  if (profileProvider.message != null &&
                                      profileProvider.message!.isNotEmpty &&
                                      profileProvider.message == "successfully")
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green.shade400,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              profileProvider.message!,
                                              style: TextStyle(
                                                color: Colors.green.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (profileProvider.message != null &&
                                      profileProvider.message!.isNotEmpty &&
                                      profileProvider.message !=
                                          "successfully") ...[
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check,
                                            color: Colors.green.shade400,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              profileProvider.message!,
                                              style: TextStyle(
                                                color: Colors.green.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  // profile card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      22,
                                      20,
                                      22,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF388E3C,
                                          ).withValues(alpha: 0.10),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // card title
                                        Row(
                                          children: [
                                            Container(
                                              width: 5,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: kPrimaryGreen,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Profile Details',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1B5E20),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        _buildInfoRow(
                                          icon: Icons.location_on_outlined,
                                          label: 'Address',
                                          value: profileProvider.isaddress,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildInfoRow(
                                          icon: Icons.phone_outlined,
                                          label: 'Phone',
                                          value: '0${profileProvider.isphone}',
                                        ),
                                        const SizedBox(height: 14),
                                        _buildInfoRow(
                                          icon: Icons.mail_outline_rounded,
                                          label: 'Email',
                                          value: profileProvider.isemail,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Continue button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Product(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryGreen,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Continue',
                                            style: kTitleStyle.copyWith(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Log out'),
                                              content: const Text(
                                                'Are you sure you want to log out?',
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Login(),
                                                          ),
                                                        );
                                                        dataProvider
                                                            .clearSecureData();
                                                      },
                                                      child: const Text('Yes'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      // Closes the dialog
                                                      child: const Text('No'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        dataProvider.clearSecureData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryGreen,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Log out",
                                        style: kTitleStyle.copyWith(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCEEDC), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF43A047)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF81C784),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
