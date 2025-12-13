import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import '../../core/services/signature_models.dart';
import 'create_signature_screen.dart';

class SignaturePickerSheet extends ConsumerWidget {
  const SignaturePickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(signatureManagerProvider);
    final signaturesAsync = ref.watch(signaturesProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'My signatures',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final created = await Navigator.of(context).push(
                      MaterialPageRoute<SignatureModel>(
                        builder: (_) => const CreateSignatureScreen(),
                      ),
                    );
                    if (created == null || !context.mounted) return;
                    Navigator.of(context).pop<SignatureModel>(created);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            signaturesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Error loading signatures: $e'),
              ),
              data: (signatures) {
                if (signatures.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        const Text('No signatures yet.'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            final created = await Navigator.of(context).push(
                              MaterialPageRoute<SignatureModel>(
                                builder: (_) => const CreateSignatureScreen(),
                              ),
                            );
                            if (created == null || !context.mounted) return;
                            Navigator.of(context).pop<SignatureModel>(created);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Create a signature'),
                        ),
                      ],
                    ),
                  );
                }

                final maxHeight = MediaQuery.sizeOf(context).height * 0.6;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: ListView.separated(
                    itemCount: signatures.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final signature = signatures[index];
                      final path = manager.resolveSignaturePath(signature);
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(signature),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        title: Text(signature.name),
                        trailing: IconButton(
                          tooltip: 'Delete',
                          onPressed: () async {
                            await ref
                                .read(signatureManagerProvider)
                                .deleteSignature(signature.id);
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
