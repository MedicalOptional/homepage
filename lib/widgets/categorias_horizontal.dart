import 'package:flutter/material.dart';

class CategoriasHorizontal extends StatefulWidget {
  const CategoriasHorizontal({super.key});

  @override
  State<CategoriasHorizontal> createState() => _CategoriasHorizontalState();
}

class _CategoriasHorizontalState extends State<CategoriasHorizontal> {
  int _selected = 0;

  static const List<_CatChip> _items = [
    _CatChip(label: 'Todos', icon: Icons.grid_view_rounded),
    _CatChip(label: 'Masculino', icon: Icons.man_outlined),
    _CatChip(label: 'Femenino', icon: Icons.woman_outlined),
    _CatChip(label: 'Infantiles', icon: Icons.child_care_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final isSelected = _selected == i;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[i].icon,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B6B6B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _items[i].label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatChip {
  final String label;
  final IconData icon;
  const _CatChip({required this.label, required this.icon});
}
