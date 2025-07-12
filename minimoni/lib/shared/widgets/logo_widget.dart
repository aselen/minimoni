import 'package:flutter/material.dart';
import '../../core/constants/assets.dart';

/// MiniMoni Logo Widget
/// Reusable logo component with different sizes
class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const LogoWidget({
    super.key,
    this.size = 120,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Image.asset(
              AppAssets.logo,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image doesn't exist
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.2),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: size * 0.4,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),

        // App Name Text
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'MiniMoni',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: textColor ?? Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: size * 0.05),
          Text(
            'Bebeğinizin Dijital Dostu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  textColor ??
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small Logo Widget for AppBar
class SmallLogoWidget extends StatelessWidget {
  final double size;

  const SmallLogoWidget({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return LogoWidget(size: size, showText: false);
  }
}
