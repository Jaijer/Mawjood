import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/item_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _uuid = Uuid();

  // Get table name based on item type
  String _getTableName(ItemType type) {
    return type == ItemType.lost ? 'lost_items' : 'found_items';
  }

  // Stream of items (lost or found)
  Stream<List<Item>> getItems(ItemType type) {
    return _supabase
        .from(_getTableName(type))
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
      return data.map((item) => Item.fromMap(item, type)).toList();
    });
  }

  // Get a single item by ID
  Future<Item?> getItemById(String id, ItemType type) async {
    final data = await _supabase
        .from(_getTableName(type))
        .select()
        .eq('id', id)
        .single();

    return data != null ? Item.fromMap(data, type) : null;
  }

  // Add an item
  Future<String> addItem(Item item) async {
    final String id = _uuid.v4();

    await _supabase.from(_getTableName(item.type)).insert({
      'id': id,
      ...item.toMap(),
    });

    return id;
  }

  // Update an item
  Future<void> updateItem(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot update item without ID');
    }

    await _supabase
        .from(_getTableName(item.type))
        .update(item.toMap())
        .eq('id', item.id);
  }

  // Delete an item
  Future<void> deleteItem(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot delete item without ID');
    }

    await _supabase
        .from(_getTableName(item.type))
        .delete()
        .eq('id', item.id);
  }

  // Mark item as resolved
  Future<void> markItemAsResolved(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot update item without ID');
    }

    await _supabase
        .from(_getTableName(item.type))
        .update({'status': 'resolved'})
        .eq('id', item.id);
  }

  // Upload image to Supabase Storage
  Future<String> uploadImage(File imageFile) async {
    final String fileExt = path.extension(imageFile.path).toLowerCase();
    final fileName = '${_uuid.v4()}$fileExt';
    final filePath = 'public/$fileName';

    await _supabase.storage
        .from('item_images')
        .upload(filePath, imageFile);

    final imageUrl = _supabase.storage
        .from('item_images')
        .getPublicUrl(filePath);

    return imageUrl;
  }

  // Delete image from Supabase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final filePath = uri.pathSegments.last;

      await _supabase.storage
          .from('item_images')
          .remove(['public/$filePath']);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}