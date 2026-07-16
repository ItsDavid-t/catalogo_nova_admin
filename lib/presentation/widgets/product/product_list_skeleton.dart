import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductListSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductListSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
