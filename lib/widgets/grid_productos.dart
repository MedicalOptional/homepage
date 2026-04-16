import 'package:flutter/material.dart';

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
                Icon(Icons.inventory_2_outlined,
                    color: const Color(0xFFBDBDBD), size: 48),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _ProductCard(
            product: products[i],
            accentColor: accentColor,
          ),
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
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
    final price = product['price']?.toString() ?? '0.00';
    final imageUrl = product['image_url']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _PlaceholderImage(color: accentColor),
                    )
                  : _PlaceholderImage(color: accentColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$$price',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      color: color.withOpacity(0.08),
      child: Center(
        child: Icon(Icons.image_outlined,
            color: color.withOpacity(0.3), size: 40),
      ),
    );
  }
}
