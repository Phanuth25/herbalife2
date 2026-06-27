// movie_pass_button.dart
import 'package:flutter/material.dart';

/// A button styled like a movie ticket, with circular cutouts
/// punched into all four corners.
///
/// Equivalent of the React `MoviePassButton` component:
/// - background: theme primary color
/// - text: theme background color
/// - corner "cutouts": small circles painted in the background color
/// - press feedback: scales down to 95% briefly (mirrors
///   `active:scale-95 transition-all duration-75`)
class MoviePassButton extends StatefulWidget {
  const MoviePassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.cutoutSize = 16.0,
    this.cutoutInset = -6.0,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;

  /// Diameter of each corner cutout circle (matches `size-4` = 16px).
  final double cutoutSize;

  /// How far the cutout pokes outside the button edge
  /// (matches `-top-1.5` / `-left-1.5` = -6px).
  final double cutoutInset;

  @override
  State<MoviePassButton> createState() => _MoviePassButtonState();
}

class _MoviePassButtonState extends State<MoviePassButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final background = colorScheme.surface; // closest analogue to `--background`
    final onPrimary = colorScheme.onPrimary; // text color on top of primary

    final half = widget.cutoutSize / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 75),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main button body
            Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: primary,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),

            // Top-left cutout
            Positioned(
              top: widget.cutoutInset,
              left: widget.cutoutInset,
              child: _Cutout(size: widget.cutoutSize, color: background),
            ),
            // Top-right cutout
            Positioned(
              top: widget.cutoutInset,
              right: widget.cutoutInset,
              child: _Cutout(size: widget.cutoutSize, color: background),
            ),
            // Bottom-right cutout
            Positioned(
              bottom: widget.cutoutInset,
              right: widget.cutoutInset,
              child: _Cutout(size: widget.cutoutSize, color: background),
            ),
            // Bottom-left cutout
            Positioned(
              bottom: widget.cutoutInset,
              left: widget.cutoutInset,
              child: _Cutout(size: widget.cutoutSize, color: background),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cutout extends StatelessWidget {
  const _Cutout({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}