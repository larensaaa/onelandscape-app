import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data model untuk setiap item menu
class TematikMenuItem {
  final String title;
  final IconData icon;

  TematikMenuItem({required this.title, required this.icon});
}

class TematikMenuGrid extends StatelessWidget {
  const TematikMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan data model untuk daftar menu yang lebih terstruktur
    final List<TematikMenuItem> menuItems = [
      TematikMenuItem(title: 'Bencana', icon: Icons.dangerous_outlined),
      TematikMenuItem(title: 'Lingkungan', icon: Icons.eco_outlined),
      TematikMenuItem(title: 'Infrastruktur', icon: Icons.domain_outlined),
      TematikMenuItem(title: 'Hayati', icon: Icons.forest_outlined),
      TematikMenuItem(title: 'Pariwisata', icon: Icons.tour_outlined),
      TematikMenuItem(title: 'Potensi SDA', icon: Icons.landscape_outlined),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 50,
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
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    // 4. Gunakan ikon dari data model
                    child: Icon(item.icon, color: Colors.grey[700], size: 30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
