import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

import '../../config/routes.dart';
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
                    onTap: () {},
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
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        elevation: 0,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(Icons.home_filled, l10n.home, 0),
              _buildNavBarItem(Icons.folder_open, l10n.files, 1),
              _buildNavBarItem(Icons.build_circle_outlined, l10n.tools, 2),
              _buildNavBarItem(Icons.settings_outlined, l10n.settings, 3),
            ],
          ),
      ),
    );
  }
  
  Widget _buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    final color = isSelected 
        ? Theme.of(context).primaryColor 
        : Theme.of(context).iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey;
        
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          context.push(AppRoutes.settings);
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
