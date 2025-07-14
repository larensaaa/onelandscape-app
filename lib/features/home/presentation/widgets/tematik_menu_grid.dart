import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data model untuk setiap item menu
class TematikMenuItem {
  final String title;
  final String iconAsset;

  TematikMenuItem({required this.title, required this.iconAsset});
}

class TematikMenuGrid extends StatelessWidget {
  const TematikMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan data model untuk daftar menu yang lebih terstruktur
    final List<TematikMenuItem> menuItems = [
      TematikMenuItem(
        title: 'Bencana & Konservasi',
        iconAsset: 'assets/images/disaster.png',
      ),
      TematikMenuItem(
        title: 'Fisik & Lingkungan',
        iconAsset: 'assets/images/environmentalism.png',
      ),
      TematikMenuItem(
        title: 'Infrastruktur',
        iconAsset: 'assets/images/infrastruktur.png',
      ),
      TematikMenuItem(
        title: 'Keanekaragaman Hayati',
        iconAsset: 'assets/images/wild-animals.png',
      ),
      TematikMenuItem(
        title: 'Parawisata',
        iconAsset: 'assets/images/travel.png',
      ),
      TematikMenuItem(
        title: 'Potensi SDA   ',
        iconAsset: 'assets/images/earth.png',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0, // Membuat item menjadi persegi
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: () {
            // 3. Tambahkan navigasi ke halaman detail dengan parameter
            context.go('/tematik-detail/${item.title}');
          },
          borderRadius: BorderRadius.circular(
            12,
          ), // Agar efek ripple sesuai bentuk
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Center(
                    // 4. Gunakan ikon dari data model
                    child: Image.asset(
                      item.iconAsset,
                      fit: BoxFit
                          .contain, // Memastikan gambar pas di dalam container
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(fontSize: 8.2, fontWeight: FontWeight.w600), 
                textAlign: TextAlign.center,
                
              ),
            ],
          ),
        );
      },
    );
  }
}
