import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductShimmer extends StatelessWidget {
  final bool isBanner;

  const ProductShimmer({
    super.key,
    this.isBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final Color highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: isBanner ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: isBanner ? 150 : 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),

        if (!isBanner) ...[
          const SizedBox(height: 12),
          _buildShimmerLine(baseColor, highlightColor, 80),
          const SizedBox(height: 8),
          _buildShimmerLine(baseColor, highlightColor, 120),
          const SizedBox(height: 8),
          _buildShimmerLine(baseColor, highlightColor, 60),
        ],
      ],
    );
  }

  Widget _buildShimmerLine(Color base, Color highlight, double width) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: 12,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}