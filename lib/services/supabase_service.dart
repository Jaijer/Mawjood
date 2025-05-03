import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/item_model.dart';
import 'package:cross_file/cross_file.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;
  final Uuid _uuid = const Uuid();

  // Table names
  static const String _lostItemsTable = 'lost_items';
  static const String _foundItemsTable = 'found_items';

  // Get table name based on item type
  String _getTableName(ItemType type) {
    return type == ItemType.lost ? _lostItemsTable : _foundItemsTable;
  }

  // Upload image to Supabase Storage
  Future<String> uploadImage(XFile imageFile) async { // Change parameter type to XFile
    try {
      final String fileName = '${_uuid.v4()}${_getFileExtension(imageFile.name)}';
      final String filePath = 'item_images/$fileName';

      // Read bytes from XFile
      final bytes = await imageFile.readAsBytes();

      await _client.storage.from('items').uploadBinary(filePath, bytes);

      final String imageUrl = _client.storage.from('items').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  String _getFileExtension(String fileName) {
    final int lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex);
  }

  // Get all items of a specific type (lost or found)
  Stream<List<Item>> getItems(ItemType type) {
    final tableName = _getTableName(type);

    return _client
        .from(tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => Item.fromMap(item, type)).toList());
  }

  // Get a single item by ID
  Future<Item?> getItemById(String? id, [ItemType? type]) async {
    if (id == null) return null;

    // If type is not specified, try both tables
    if (type == null) {
      try {
        final lostItem = await _client
            .from(_lostItemsTable)
            .select()
            .eq('id', id)
            .single();
        return Item.fromMap(lostItem, ItemType.lost);
      } catch (_) {
        try {
          final foundItem = await _client
              .from(_foundItemsTable)
              .select()
              .eq('id', id)
              .single();
          return Item.fromMap(foundItem, ItemType.found);
        } catch (e) {
          return null;
        }
      }
    }

    // If type is specified, query the appropriate table
    try {
      final tableName = _getTableName(type);
      final data = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();
      return Item.fromMap(data, type);
    } catch (e) {
      print('Error getting item by ID: $e');
      return null;
    }
  }

  // Add a new item
  Future<void> addItem(Item item) async {
    try {
      final tableName = _getTableName(item.type);

      await _client.from(tableName).insert(item.toMap());
    } catch (e) {
      print('Error adding item: $e');
      throw Exception('Failed to add item: $e');
    }
  }

  // Update an existing item
  Future<void> updateItem(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot update item with null ID');
    }

    try {
      final tableName = _getTableName(item.type);

      await _client
          .from(tableName)
          .update(item.toMap())
          .eq('id', item.id);
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Failed to update item: $e');
    }
  }

  // Mark an item as resolved
  Future<void> markItemAsResolved(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot update item with null ID');
    }

    try {
      final tableName = _getTableName(item.type);
      final updatedItem = item.copyWith(status: ItemStatus.resolved);

      await _client
          .from(tableName)
          .update({'status': 'resolved'})
          .eq('id', item.id);
    } catch (e) {
      print('Error marking item as resolved: $e');
      throw Exception('Failed to mark item as resolved: $e');
    }
  }

  // Delete an item
  Future<void> deleteItem(Item item) async {
    if (item.id == null) {
      throw Exception('Cannot delete item with null ID');
    }

    try {
      final tableName = _getTableName(item.type);

      // Delete the item
      await _client
          .from(tableName)
          .delete()
          .eq('id', item.id);

      // Optionally delete associated images
      for (String imageUrl in item.imageUrls) {
        try {
          // Extract file path from URL
          final Uri uri = Uri.parse(imageUrl);
          final String filePath = uri.pathSegments.last;

          await _client.storage.from('items').remove(['item_images/$filePath']);
        } catch (e) {
          print('Error deleting image: $e');
          // Continue with other images even if one fails
        }
      }
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Failed to delete item: $e');
    }
  }

  // Search for items by title or description
  Future<List<Item>> searchItems(String query, ItemType type) async {
    try {
      final tableName = _getTableName(type);

      final data = await _client
          .from(tableName)
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return data.map((item) => Item.fromMap(item, type)).toList();
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }

  // Get items filtered by category
  Future<List<Item>> filterItemsByCategory(String category, ItemType type) async {
    try {
      final tableName = _getTableName(type);

      final data = await _client
          .from(tableName)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return data.map((item) => Item.fromMap(item, type)).toList();
    } catch (e) {
      print('Error filtering items by category: $e');
      return [];
    }
  }
}