import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

import '../../config/routes.dart';
import '../../core/services/providers.dart';
import '../../core/widgets/glass_toolbar.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';
import '../camera/providers/camera_provider.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/document_card.dart';

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
  final Set<String> _selectedDocumentIds = {};

  bool get _isSelectionMode => _selectedDocumentIds.isNotEmpty;

  void _toggleSelection(String documentId) {
    setState(() {
      if (_selectedDocumentIds.contains(documentId)) {
        _selectedDocumentIds.remove(documentId);
      } else {
        _selectedDocumentIds.add(documentId);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedDocumentIds.clear);
  }

  Future<void> _mergeSelected(BuildContext context) async {
    if (_selectedDocumentIds.length < 2) return;

    final manager = ref.read(documentManagerProvider);
    LoadingOverlay.show(context, message: 'Merging...');
    try {
      final merged = await manager.mergeDocuments(
        documentIds: _selectedDocumentIds.toList(),
      );
      if (!context.mounted) return;
      LoadingOverlay.hide(context);
      _clearSelection();
      context.push('${AppRoutes.editor}?docId=${merged.id}');
    } catch (e) {
      if (!context.mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error merging: $e')));
    }
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedDocumentIds.isEmpty) return;
    final manager = ref.read(documentManagerProvider);

    LoadingOverlay.show(context, message: 'Deleting...');
    try {
      final ids = _selectedDocumentIds.toList();
      for (final id in ids) {
        await manager.deleteDocument(id);
      }
      if (!context.mounted) return;
      LoadingOverlay.hide(context);
      _clearSelection();
    } catch (e) {
      if (!context.mounted) return;
      LoadingOverlay.hide(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
                            _isSelectionMode
                                ? '${_selectedDocumentIds.length} selected'
                                : l10n.newScansToday(3),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFFFCCBC),
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withValues(alpha: 0.5),
                        ),
                        hintText: l10n.searchPlaceholder,
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.5),
                            ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {},
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
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
                        onTap: () async {
                          final pick = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: const ['pdf'],
                            withData: false,
                          );
                          final path = pick?.files.single.path;
                          if (path == null || path.isEmpty) return;
                          if (!context.mounted) return;

                          LoadingOverlay.show(
                            context,
                            message: 'Importing PDF...',
                          );
                          try {
                            final manager = ref.read(documentManagerProvider);
                            final pages = await manager.rasterizePdfToPages(
                              File(path),
                            );
                            if (!context.mounted) return;

                            ref
                                .read(scanStateProvider.notifier)
                                .setCapturedImages(pages);
                            LoadingOverlay.hide(context);
                            if (!context.mounted) return;

                            context.push(
                              '${AppRoutes.editor}?source=importPdf',
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            LoadingOverlay.hide(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error importing PDF: $e'),
                              ),
                            );
                          }
                        },
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
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Document List
                  Expanded(
                    child: ref
                        .watch(documentsProvider)
                        .when(
                          data: (documents) {
                            if (documents.isEmpty) {
                              return const Center(
                                child: Text('No documents yet'),
                              );
                            }

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final doc = documents[index];
                                final isSelected = _selectedDocumentIds
                                    .contains(doc.id);
                                return DocumentCard(
                                  document: doc,
                                  isSelected: isSelected,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      _toggleSelection(doc.id);
                                    } else {
                                      context.push(
                                        '${AppRoutes.editor}?docId=${doc.id}',
                                      );
                                    }
                                  },
                                  onLongPress: () => _toggleSelection(doc.id),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(
                            child: Text('Error loading documents: $e'),
                          ),
                        ),
                  ),
                ],
              ),
            ),
            if (_isSelectionMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: GlassToolbar(
                  margin: EdgeInsets.only(
                    bottom: 96 + MediaQuery.paddingOf(context).bottom,
                    left: 24,
                    right: 24,
                  ),
                  items: [
                    GlassToolbarItem(
                      icon: Icons.merge,
                      label: 'Merge',
                      onTap: () => _mergeSelected(context),
                    ),
                    GlassToolbarItem(
                      icon: Icons.delete_outline,
                      label: l10n.delete,
                      onTap: () => _deleteSelected(context),
                    ),
                    GlassToolbarItem(
                      icon: Icons.check_circle_outlined,
                      label: l10n.deselect,
                      onTap: _clearSelection,
                    ),
                  ],
                ),
              ),
          ],
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
          AppBottomNavItem(
            icon: Icons.build_circle_outlined,
            label: l10n.tools,
          ),
          AppBottomNavItem(icon: Icons.settings_outlined, label: l10n.settings),
        ],
      ),
    );
  }
}
