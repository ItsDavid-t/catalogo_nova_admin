import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryListSkeleton extends StatelessWidget {
  final int itemCount;

  const CategoryListSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) => _buildSkeletonItem(),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      height: 40,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
