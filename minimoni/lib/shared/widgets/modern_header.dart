import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';

/// Luxury, elegant header widget with glassmorphism and smooth animations
class ModernHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String emoji;
  final bool showBackButton;
  final bool showProfileButton;
  final VoidCallback? onBackPressed;
  final bool isDashboard;

  const ModernHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.emoji,
    this.showBackButton = false,
    this.showProfileButton = false,
    this.onBackPressed,
    this.isDashboard = false,
  });

  @override
  State<ModernHeader> createState() => _ModernHeaderState();
}

class _ModernHeaderState extends State<ModernHeader>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _shimmerController;
  late Animation<double> _headerAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Header slide animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _headerController.forward();
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final isSmall = width < 350;
    final isMedium = width < 400;
    // Even more compact responsive sizes
    final double logoSize =
        widget.isDashboard
            ? (isSmall
                ? 28
                : isMedium
                ? 34
                : 40)
            : (isSmall ? 18 : 22);
    final double emojiSize =
        widget.isDashboard ? (isSmall ? 16 : 20) : (isSmall ? 14 : 16);
    final double titleFont =
        isSmall
            ? 13
            : isMedium
            ? 15
            : 17;
    final double subtitleFont = isSmall ? 9 : 10;
    final double buttonSize = isSmall ? 28 : 32;
    final double headerHeight =
        widget.isDashboard ? (isSmall ? 48 : 58) : (isSmall ? 40 : 48);
    final double horizontalPad = isSmall ? 4 : 8;
    final double verticalPad = isSmall ? 2 : 6;

    return SliverAppBar(
      expandedHeight: headerHeight + topPad,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration:
              widget.isDashboard
                  ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.90),
                        Colors.white.withOpacity(0.70),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  )
                  : null,
          padding: EdgeInsets.fromLTRB(
            horizontalPad,
            verticalPad + topPad,
            horizontalPad,
            verticalPad,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.showBackButton) _buildBackButton(context, buttonSize),
              if (widget.isDashboard && !widget.showBackButton)
                _buildLogoSection(logoSize)
              else if (!widget.isDashboard && !widget.showBackButton)
                _buildEmojiSection(emojiSize),
              if (!widget.showBackButton) SizedBox(width: isSmall ? 4 : 8),
              Expanded(
                child: _buildTitleSection(titleFont, subtitleFont, emojiSize),
              ),
              if (widget.showProfileButton)
                _buildProfileButton(context, buttonSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.20),
              const Color(0xFFFFE4E1).withOpacity(0.15),
              const Color(0xFFF0F8E8).withOpacity(0.10),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3 * _shimmerAnimation.value),
                    Colors.transparent,
                    Colors.white.withOpacity(0.2 * _shimmerAnimation.value),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      children: [
        // Back button
        if (widget.showBackButton) _buildLuxuryBackButton(),

        // Logo section (only for dashboard)
        if (!widget.showBackButton) _buildLuxuryLogoSection(),

        // Spacer
        if (!widget.showBackButton) const SizedBox(width: 16),

        // Title section
        Expanded(child: _buildLuxuryTitleSection()),

        // Profile button
        if (widget.showProfileButton) _buildLuxuryProfileButton(),
      ],
    );
  }

  Widget _buildLuxuryBackButton() {
    return Container(
          margin: const EdgeInsets.only(right: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onBackPressed ?? () => context.pop(),
              borderRadius: BorderRadius.circular(16),
              child: GlassmorphicContainer(
                width: 44,
                height: 44,
                borderRadius: 16,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF2D3748),
                  size: 20,
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideX(begin: -0.3, end: 0, duration: 600.ms, delay: 200.ms);
  }

  Widget _buildLuxuryLogoSection() {
    return Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFE4E1).withOpacity(0.8),
                const Color(0xFFF0F8E8).withOpacity(0.7),
                Colors.white.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFE4E1).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 800.ms)
        .shimmer(duration: 1200.ms, delay: 400.ms);
  }

  Widget _buildLuxuryTitleSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Animated emoji
            Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  delay: 300.ms,
                ),

            const SizedBox(width: 10),

            // Luxury title
            Flexible(
              child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A202C),
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
                  .slideX(begin: 0.3, end: 0, duration: 800.ms, delay: 400.ms),
            ),
          ],
        ),

        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
                widget.subtitle!,
                style: GoogleFonts.inter(
                  color: const Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  letterSpacing: -0.1,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 600.ms),
        ],
      ],
    );
  }

  Widget _buildLuxuryProfileButton() {
    return Container(
          margin: const EdgeInsets.only(left: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/dashboard/profile'),
              borderRadius: BorderRadius.circular(16),
              child: GlassmorphicContainer(
                width: 44,
                height: 44,
                borderRadius: 16,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF2D3748),
                  size: 22,
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideX(begin: 0.3, end: 0, duration: 600.ms, delay: 500.ms);
  }

  Widget _buildBackButton(BuildContext context, double size) {
    return Container(
      margin: EdgeInsets.only(right: size * 0.3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onBackPressed ?? () => context.pop(),
          borderRadius: BorderRadius.circular(size * 0.4),
          child: GlassmorphicContainer(
            width: size,
            height: size,
            borderRadius: size * 0.4,
            blur: 20,
            alignment: Alignment.center,
            border: 1.5,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: const Color(0xFF2D3748),
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFE4E1).withOpacity(0.8),
            const Color(0xFFF0F8E8).withOpacity(0.7),
            Colors.white.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE4E1).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.18),
          child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildEmojiSection(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Text(widget.emoji, style: TextStyle(fontSize: size)),
    );
  }

  Widget _buildTitleSection(
    double titleFont,
    double subtitleFont,
    double emojiSize,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (!widget.isDashboard)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text(
                  widget.emoji,
                  style: TextStyle(fontSize: emojiSize),
                ),
              ),
            Flexible(
              child: Text(
                widget.title,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A202C),
                  fontWeight: FontWeight.w800,
                  fontSize: titleFont,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        if (widget.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              widget.subtitle!,
              style: GoogleFonts.inter(
                color: const Color(0xFF718096),
                fontWeight: FontWeight.w500,
                fontSize: subtitleFont,
                letterSpacing: -0.1,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context, double size) {
    return Container(
      margin: EdgeInsets.only(left: size * 0.3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/dashboard/profile'),
          borderRadius: BorderRadius.circular(size * 0.4),
          child: GlassmorphicContainer(
            width: size,
            height: size,
            borderRadius: size * 0.4,
            blur: 20,
            alignment: Alignment.center,
            border: 1.5,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Icon(
              Icons.person_outline,
              color: const Color(0xFF2D3748),
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}
