import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data model untuk setiap item menu
class TematikMenuItem {
  final String title;
  final String iconAsset;
  final String route;

  TematikMenuItem({
    required this.title,
    required this.iconAsset,
    required this.route,
  });
}

class TematikMenuGrid extends StatelessWidget {
  const TematikMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TematikMenuItem> menuItems = [
      TematikMenuItem(
        title: 'Bencana & Konservasi',
        iconAsset: 'assets/images/disaster.png',
        route: '/map-full',
      ),
      TematikMenuItem(
        title: 'Fisik & Lingkungan',
        iconAsset: 'assets/images/environmentalism.png',
        route: '/map-full',
      ),
      TematikMenuItem(
        title: 'Infrastruktur',
        iconAsset: 'assets/images/infrastruktur.png',
        route: '/map-full',
      ),
      TematikMenuItem(
        title: 'Keanekaragaman Hayati',
        iconAsset: 'assets/images/wild-animals.png',
        route: '/map-full',
      ),
      TematikMenuItem(
        title: 'Parawisata',
        iconAsset: 'assets/images/travel.png',
        route: '/map-full',
      ),
      TematikMenuItem(
        title: 'Potensi SDA   ',
        iconAsset: 'assets/images/earth.png',
        route: '/map-full',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: () {
            context.push(item.route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Center(
                    child: Image.asset(item.iconAsset, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 8.2,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
