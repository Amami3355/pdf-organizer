import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/glass_toolbar.dart';
import '../../core/painters/dashed_border_painter.dart';

/// ✏️ Editor Screen
/// 
/// PDF page management and editing tools.
/// Uses Riverpod for consistency across the app.

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Contract_Scan_FINAL.pdf',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${l10n.pages(3)} • 2.4 MB',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              l10n.export,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.70,
              children: [
                _buildPageCard(context, 1, false),
                _buildPageCard(context, 2, false),
                _buildPageCard(context, 3, true),
                _buildAddPageCard(context, l10n),
              ],
            ),
          ),
          
          // Bottom Toolbar with Glassmorphism
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassToolbar(
              items: [
                GlassToolbarItem(icon: Icons.edit_outlined, label: l10n.sign),
                GlassToolbarItem(icon: Icons.compress, label: l10n.compress),
                GlassToolbarItem(icon: Icons.crop, label: l10n.extract),
                GlassToolbarItem(icon: Icons.more_horiz, label: l10n.more),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(BuildContext context, int pageNumber, bool isSelected) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  border: isSelected
                      ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 8, width: 60, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      for (int i = 0; i < 6; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(height: 4, width: double.infinity, color: Colors.grey[300]),
                        ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$pageNumber',
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddPageCard(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              strokeWidth: 1.5,
              gap: 5,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                      ),
                      child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addPage,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(''),
      ],
    );
  }
}
