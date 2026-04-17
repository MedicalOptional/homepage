import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import '../services/api_service.dart';
import '../screens/login.dart';
import '../screens/product_detail.dart';

class GridProductos extends StatelessWidget {
  final List<dynamic> products;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final Color accentColor;

  const GridProductos({
    super.key,
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.accentColor = const Color(0xFF1A1A2E),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: accentColor),
          ),
        ),
      );
    }

    if (error != null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Color(0xFFD32F2F), size: 40),
                const SizedBox(height: 12),
                Text(error!,
                    style: const TextStyle(
                        color: Color(0xFF6B6B6B), fontSize: 13)),
                const SizedBox(height: 16),
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reintentar'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFFBDBDBD), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'No hay productos disponibles',
                  style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
                ),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    child: Text('Actualizar',
                        style: TextStyle(color: accentColor)),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _ProductCard(
            product: products[i],
            accentColor: accentColor,
          ),
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final Color accentColor;

  const _ProductCard({required this.product, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Producto';
    final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
    final originalPrice = double.tryParse(product['original_price']?.toString() ?? '0') ?? 0.0;
    final imageUrl = product['image_url']?.toString() ?? '';
    final hasDiscount = originalPrice > price && originalPrice > 0;
    final discountPct = hasDiscount
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            color: const Color(0xFFF5F5F5),
                            colorBlendMode: BlendMode.multiply,
                            errorBuilder: (_, __, ___) =>
                                _PlaceholderImage(color: accentColor),
                          )
                        : _PlaceholderImage(color: accentColor),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8174A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '-$discountPct%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (hasDiscount)
                    Text(
                      '\$ ${originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF9E9E9E),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '\$ ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
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

class _PlaceholderImage extends StatelessWidget {
  final Color color;
  const _PlaceholderImage({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Icon(Icons.image_outlined,
            color: color.withOpacity(0.3), size: 32),
      ),
    );
  }
}
