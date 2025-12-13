import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'signature_models.dart';

class SignatureManager {
  SignatureManager._();

  static final SignatureManager instance = SignatureManager._();

  static const String _boxName = 'signatures_data';

  bool _initialized = false;
  late final Box _box;
  late final Directory _baseDir;

  Directory get signaturesDir => Directory('${_baseDir.path}/signatures');

  Future<void> init() async {
    if (_initialized) return;

    _box = await Hive.openBox(_boxName);
    _baseDir = await getApplicationDocumentsDirectory();
    await signaturesDir.create(recursive: true);
    _initialized = true;

    debugPrint('SignatureManager: Initialized (${_baseDir.path})');
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('SignatureManager not initialized. Call init() first.');
    }
  }

  String get baseDirPath {
    _ensureInitialized();
    return _baseDir.path;
  }

  String resolveSignaturePath(SignatureModel signature) {
    _ensureInitialized();
    return File('${_baseDir.path}/${signature.fileName}').path;
  }

  List<SignatureModel> _readAllSync() {
    final list = <SignatureModel>[];
    for (final entry in _box.toMap().entries) {
      final value = entry.value;
      if (value is! Map) continue;
      try {
        list.add(SignatureModel.fromJson(Map<String, dynamic>.from(value)));
      } catch (e) {
        debugPrint('SignatureManager: Failed to parse signature: $e');
      }
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<SignatureModel>> listSignatures() async {
    _ensureInitialized();
    return _readAllSync();
  }

  Stream<List<SignatureModel>> watchSignatures() async* {
    _ensureInitialized();
    yield _readAllSync();
    await for (final _ in _box.watch()) {
      yield _readAllSync();
    }
  }

  SignatureModel? getSignatureSync(String signatureId) {
    _ensureInitialized();
    final raw = _box.get(signatureId);
    if (raw is! Map) return null;
    return SignatureModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<SignatureModel> createSignature({
    required Uint8List pngBytes,
    String name = '',
  }) async {
    _ensureInitialized();
    if (pngBytes.isEmpty) {
      throw ArgumentError.value(pngBytes, 'pngBytes', 'Must not be empty');
    }

    final id = _newId();
    final now = DateTime.now();
    final safeName = name.trim().isEmpty
        ? 'Signature ${_formatShort(now)}'
        : name.trim();

    final fileName = 'signatures/$id.png';
    final file = File('${_baseDir.path}/$fileName');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(pngBytes, flush: true);

    final model = SignatureModel(
      id: id,
      name: safeName,
      fileName: fileName,
      createdAt: now,
    );
    await _box.put(id, model.toJson());
    return model;
  }

  Future<void> deleteSignature(String signatureId) async {
    _ensureInitialized();
    final existing = getSignatureSync(signatureId);
    await _box.delete(signatureId);

    final fileName = existing?.fileName;
    if (fileName == null) return;
    final file = File('${_baseDir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _newId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  String _formatShort(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
