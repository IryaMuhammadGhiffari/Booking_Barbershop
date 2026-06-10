import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Reusable shimmer loading widget. Cocok untuk placeholder card/list.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

/// Shimmer list — render [count] shimmer cards memenuhi layar.
/// Gunakan saat loading list/data agar transisi ke konten asli terasa natural.
class ShimmerList extends StatelessWidget {
  final int count;
  final Widget Function() itemBuilder;

  const ShimmerList({super.key, this.count = 5, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => itemBuilder(),
    );
  }
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.surface;
    final highlight = widget.highlightColor ?? AppColors.divider;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer untuk card booking
class ShimmerBookingCard extends StatelessWidget {
  const ShimmerBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 140, height: 14, borderRadius: 4),
              ShimmerLoading(width: 80, height: 22, borderRadius: 12),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              ShimmerLoading(width: 100, height: 14, borderRadius: 4),
              SizedBox(width: 16),
              ShimmerLoading(width: 80, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              ShimmerLoading(width: 120, height: 14, borderRadius: 4),
              SizedBox(width: 16),
              ShimmerLoading(width: 60, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 16),
          ShimmerLoading(width: double.infinity, height: 36, borderRadius: 10),
        ],
      ),
    );
  }
}

/// Shimmer untuk card layanan
class ShimmerServiceCard extends StatelessWidget {
  const ShimmerServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const ShimmerLoading(height: 100, borderRadius: 10),
          ),
          const SizedBox(height: 12),
          const ShimmerLoading(width: 140, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          const ShimmerLoading(width: 100, height: 12, borderRadius: 4),
          const SizedBox(height: 10),
          const ShimmerLoading(width: 80, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Shimmer untuk card barber
class ShimmerBarberCard extends StatelessWidget {
  const ShimmerBarberCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: const Column(
        children: [
          ShimmerLoading(width: 80, height: 80, borderRadius: 40),
          SizedBox(height: 10),
          ShimmerLoading(width: 100, height: 14, borderRadius: 4),
          SizedBox(height: 4),
          ShimmerLoading(width: 60, height: 11, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Shimmer untuk card admin booking
class ShimmerAdminCard extends StatelessWidget {
  const ShimmerAdminCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 120, height: 12, borderRadius: 4),
              ShimmerLoading(width: 90, height: 22, borderRadius: 12),
            ],
          ),
          SizedBox(height: 14),
          ShimmerLoading(width: 160, height: 15, borderRadius: 4),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ShimmerLoading(height: 28, borderRadius: 6)),
              SizedBox(width: 10),
              Expanded(child: ShimmerLoading(height: 28, borderRadius: 6)),
            ],
          ),
        ],
      ),
    );
  }
}
