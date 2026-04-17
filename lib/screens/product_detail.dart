import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import '../services/api_service.dart';
import 'login.dart';
import 'cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  bool _adding = false;
  bool _descExpanded = false;
  bool _specsExpanded = false;

  List<String> get _sizes {
    final raw = widget.product['sizes'];
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  Future<void> _handleAddToCart() async {
    if (!authState.isLoggedIn) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Inicia sesion',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          content: const Text(
            'Para agregar productos al carrito necesitas iniciar sesion.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF6B6B6B))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Iniciar sesion'),
            ),
          ],
        ),
      );

      if (shouldLogin == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    setState(() => _adding = true);
    try {
      final product = Map<String, dynamic>.from(widget.product);
      await ApiService.addToCart(authState.userId!, product, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${product['name'] ?? 'Producto'} agregado al carrito'),
            backgroundColor: const Color(0xFF1A5C3A),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al agregar al carrito'),
            backgroundColor: Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.product['name']?.toString() ?? 'Producto';
    final brand = widget.product['brand']?.toString() ?? '';
    final color = widget.product['color']?.toString() ?? '';
    final price =
        double.tryParse(widget.product['price']?.toString() ?? '0') ?? 0.0;
    final originalPrice =
        double.tryParse(widget.product['original_price']?.toString() ?? '0') ??
            0.0;
    final imageUrl = widget.product['image_url']?.toString() ?? '';
    final description = widget.product['description']?.toString() ?? '';
    final hasDiscount = originalPrice > price && originalPrice > 0;
    final sizes = _sizes;

    final Map<String, String> specs = {};
    final rawSpecs = widget.product['specs'];
    if (rawSpecs is Map) {
      rawSpecs.forEach((k, v) => specs[k.toString()] = v.toString());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                expandedHeight: 340,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: Color(0xFF1A1A2E)),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      if (!authState.isLoggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CartScreen()),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.shopping_bag_outlined,
                            size: 20, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container(
                        color: const Color(0xFFF5F5F5),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_outlined,
                                      size: 80, color: Color(0xFFBDBDBD)),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.image_outlined,
                                    size: 80, color: Color(0xFFBDBDBD)),
                              ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite_border,
                              size: 20, color: Color(0xFF1A1A2E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                      if (brand.isNotEmpty || color.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            [if (brand.isNotEmpty) brand, if (color.isNotEmpty) color].join(' \u2022 '),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              '\$ ${originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9E9E9E),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '\$ ${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                      if (sizes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Talla',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sizes.map((size) {
                            final isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSize = size),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1A1A2E)
                                        : const Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.straighten,
                                size: 16,
                                color: Color(0xFF6B6B6B),
                              ),
                              label: const Text(
                                'Tabla de tallas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFE0E0E0)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 4),
                      const Text(
                        'Vendido y entregado por ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _descExpanded = !_descExpanded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Descripcion del producto',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Icon(
                                _descExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ],
                          ),
                        ),
                        if (_descExpanded)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B6B6B),
                                height: 1.6,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF0F0F0)),
                      ],
                      if (specs.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _specsExpanded = !_specsExpanded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Especificaciones',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Icon(
                                _specsExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ],
                          ),
                        ),
                        if (_specsExpanded)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: specs.entries.toList().asMap().entries.map((entry) {
                                final i = entry.key;
                                final spec = entry.value;
                                return Column(
                                  children: [
                                    if (i > 0)
                                      const Divider(
                                          height: 1,
                                          color: Color(0xFFE8E8E8)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            spec.key,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B6B6B),
                                            ),
                                          ),
                                          Text(
                                            spec.value,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _adding ? null : _handleAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    elevation: 0,
                  ),
                  child: _adding
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Agregar al carrito',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
