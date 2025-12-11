import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/quick_action_button.dart';
import '../components/document_card.dart';
import '../data/dummy_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                        'Good evening, Alex',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have 3 new scans today',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFFFCCBC), // Light peach
                    child: Text('A', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    hintText: 'Search documents, PDFs, OCR',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune, color: AppTheme.primary),
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
                    label: 'Scan New',
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.cloud_upload,
                    label: 'Import',
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.build,
                    label: 'Tools',
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
                    'Recent Documents',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primary,
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
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF4CA6FF), Color(0xFF0056D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x400056D2),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.document_scanner_outlined, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.background,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(right: 80.0), // Space for FAB
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(context, Icons.home_filled, 'Home', true),
              _buildNavBarItem(context, Icons.folder_open, 'Files', false),
              _buildNavBarItem(context, Icons.build_circle_outlined, 'Tools', false),
              _buildNavBarItem(context, Icons.settings_outlined, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavBarItem(BuildContext context, IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
