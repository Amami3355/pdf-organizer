import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

import '../../config/routes.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/document_card.dart';
import 'data/dummy_data.dart';

/// 🏠 Home Screen (Dashboard)
/// 
/// Main app screen showing recent documents and quick actions.
/// Uses Riverpod for consistency across the app.

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.greeting('Alex'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.newScansToday(3),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFFFCCBC),
                    child: Text('A', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5)),
                    hintText: l10n.searchPlaceholder,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.tune, color: Theme.of(context).primaryColor),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Actions
              Row(
                children: [
                  QuickActionButton(
                    icon: Icons.camera_alt,
                    label: l10n.scanNew,
                    onTap: () => context.push(AppRoutes.camera),
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.cloud_upload,
                    label: l10n.import,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.build,
                    label: l10n.tools,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent Documents Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentDocuments,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.seeAll,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Document List
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.recentDocuments.length,
                  itemBuilder: (context, index) {
                    return DocumentCard(
                      document: DummyData.recentDocuments[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      

      
      // Bottom Navigation Bar
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemTapped: (index) {
          if (index == 3) {
            context.push(AppRoutes.settings);
          } else {
            setState(() => _selectedNavIndex = index);
          }
        },
        items: [
          AppBottomNavItem(icon: Icons.home_filled, label: l10n.home),
          AppBottomNavItem(icon: Icons.folder_open, label: l10n.files),
          AppBottomNavItem(icon: Icons.build_circle_outlined, label: l10n.tools),
          AppBottomNavItem(icon: Icons.settings_outlined, label: l10n.settings),
        ],
      ),
    );
  }
}
