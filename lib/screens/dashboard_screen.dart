import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Safe to call provider methods here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppImageProvider>().fetchTrendingImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppImageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1200) crossAxisCount = 4;
            else if (constraints.maxWidth > 800) crossAxisCount = 3;
            else if (constraints.maxWidth > 600) crossAxisCount = 2;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.images.length,
              itemBuilder: (context, index) => ImageCard(hit: provider.images[index]),
            );
          },
        );
      },
    );
  }
}