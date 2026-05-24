import 'package:flutter/material.dart';

class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
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
    _animation = Tween<double>(begin: -2, end: 2).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  final double leadingSize;
  final double titleWidth;
  final double subtitleWidth;

  const SkeletonListTile({
    super.key,
    this.leadingSize = 48,
    this.titleWidth = 0.6,
    this.subtitleWidth = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          SkeletonWidget(
            width: leadingSize,
            height: leadingSize,
            borderRadius: leadingSize / 2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidget(
                  width: MediaQuery.of(context).size.width * titleWidth,
                  height: 14,
                ),
                const SizedBox(height: 8),
                SkeletonWidget(
                  width: MediaQuery.of(context).size.width * subtitleWidth,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SkeletonWidget(height: height, borderRadius: 16),
    );
  }
}

class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonWidget(width: 180, height: 22),
                    const SizedBox(height: 8),
                    SkeletonWidget(width: 120, height: 14),
                  ],
                ),
              ),
              SkeletonWidget(width: 52, height: 52, borderRadius: 26),
            ],
          ),
          const SizedBox(height: 24),
          SkeletonWidget(height: 180, borderRadius: 20),
          const SizedBox(height: 24),
          SkeletonWidget(width: 140, height: 18),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SkeletonWidget(height: 100, borderRadius: 16)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonWidget(height: 100, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonWidget(height: 100, borderRadius: 16)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonWidget(height: 100, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),
          SkeletonWidget(width: 160, height: 18),
          const SizedBox(height: 16),
          SkeletonWidget(height: 80, borderRadius: 16),
          const SizedBox(height: 12),
          SkeletonWidget(height: 80, borderRadius: 16),
        ],
      ),
    );
  }
}

class SkeletonListPage extends StatelessWidget {
  final int itemCount;

  const SkeletonListPage({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}

class SkeletonDetailPage extends StatelessWidget {
  const SkeletonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonWidget(width: 40, height: 40, borderRadius: 8),
              const SizedBox(width: 12),
              SkeletonWidget(width: 200, height: 14),
            ],
          ),
          const SizedBox(height: 20),
          SkeletonWidget(height: 200, borderRadius: 16),
          const SizedBox(height: 24),
          SkeletonWidget(width: 160, height: 20),
          const SizedBox(height: 12),
          SkeletonWidget(height: 14),
          const SizedBox(height: 8),
          SkeletonWidget(width: 0.85, height: 14),
          const SizedBox(height: 8),
          SkeletonWidget(width: 0.7, height: 14),
          const SizedBox(height: 24),
          SkeletonWidget(width: 140, height: 20),
          const SizedBox(height: 12),
          SkeletonWidget(height: 14),
          const SizedBox(height: 8),
          SkeletonWidget(width: 0.9, height: 14),
          const SizedBox(height: 8),
          SkeletonWidget(width: 0.6, height: 14),
          const SizedBox(height: 24),
          SkeletonWidget(width: 120, height: 20),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonWidget(height: 60, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonWidget(height: 60, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonWidget(height: 60, borderRadius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
