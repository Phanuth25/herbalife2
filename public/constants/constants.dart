import 'package:flutter/material.dart';


const String accounturl = "http://10.0.2.2:3000/api";
// Colors
const Color kPrimaryGreen = Color(0xFF2E6A38);

// Text Styles
const TextStyle kTitleStyle = TextStyle(
  color: kPrimaryGreen,
  fontWeight: FontWeight.bold,
  fontSize: 20,
);

const TextStyle kHintStyle = TextStyle(
  fontWeight: FontWeight.bold,
);

// TextField Decoration Builder
InputDecoration kTextFieldDecoration({required String hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: kHintStyle,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kPrimaryGreen, width: 3.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: kPrimaryGreen, width: 3.5),
    ),
  );
}

// Button Style
final ButtonStyle kButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimaryGreen,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  minimumSize: const Size(200, 50),
);

class LoginContainer extends StatelessWidget {
  final Widget child;

  const LoginContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryGreen, width: 5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: child,
      ),
    );
  }
}

// 3. LoginButton
class LoginButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;

  const LoginButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: kButtonStyle,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
        label,
        style: textStyle ?? kTitleStyle.copyWith(color: Colors.white),
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextStyle? textStyle;
  final IconData icon;
  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.textStyle,
    required this.icon,

  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: textStyle ?? kTitleStyle,
        decoration: kTextFieldDecoration(hintText: hintText).copyWith(
          prefixIcon: Icon(icon, color: kPrimaryGreen),
        ),
      ),
    );
  }
}
