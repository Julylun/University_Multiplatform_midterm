import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SafeAvatar extends StatelessWidget {
  final String imageUrl;
  final String fallbackName;
  final double radius;

  const SafeAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackName,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = ApiService.normalizeImageUrl(imageUrl);

    if (normalized.isEmpty) {
      return _buildFallback(context);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ClipOval(
        child: Image.network(
          normalized,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(context);
          },
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final initial = fallbackName.trim().isNotEmpty
        ? fallbackName.trim().substring(0, 1).toUpperCase()
        : 'G';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
